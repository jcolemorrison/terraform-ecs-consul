# User Facing Client Task Definition
# --
# This is the container that will serve as the entry point for public facing traffic
module "client" {
  source            = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version           = "0.4.2"

  family = "${local.project_tag}-client"

  # required for Fargate launch type
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  # not needed, the module will add both an execution and task role
  # execution_role_arn = aws_iam_role.task_execution_role.arn

  # `jsonencode` is NOT needed with this module
  # likely because the module is doing that for us: https://github.com/hashicorp/terraform-aws-consul-ecs/blob/main/modules/mesh-task/main.tf#L37
  # since jsonencode turns it into a string, we'd lose our ability to do a "for" statement
  container_definitions = [
    {
      name = "client"
      image = "nicholasjackson/fake-service:v0.23.1"
      cpu = 0 # take up proportional cpu
      essential = true

      portMappings = [
        {
          containerPort = 9090
          hostPort = 9090 # though, access to the ephemeral port range is needed to connect on EC2, the exact port is required on Fargate from a security group standpoint.
          protocol = "tcp"
        }
      ]

      logConfiguration = local.client_logs_configuration

      # Fake Service settings are set via Environment variables
      environment = [
        {
          name = "NAME" # Fake Service name
          value = "client" 
        },
        {
          name = "MESSAGE" # Fake Service message to return
          value = "Hello from the client!"
        },
        {
          name = "UPSTREAM_URIS" # Fake service upstream service to call to
          value = "http://localhost:1234,http://localhost:1235,http://localhost:1236" # point all upstreams to the proxy
        }
      ]
    }
  ]

  # All settings required by the mesh-task module
  acls = true

  # this option is going away post consul-ecs 0.4.2
  acl_secret_name_prefix = local.project_tag

  consul_datacenter = var.consul_dc_1
  consul_server_ca_cert_arn = aws_secretsmanager_secret.consul_root_ca_cert.arn
  consul_client_token_secret_arn = module.consul_acl_controller.client_token_secret_arn
  gossip_key_secret_arn = aws_secretsmanager_secret.consul_gossip_key.arn
  log_configuration = local.client_sidecars_log_configuration
  
  # https://github.com/hashicorp/consul-ecs/blob/main/config/schema.json#L74#
  # to tell the proxy and consul-ecs how to contact the service
  port = "9090" 

  tls = true

  # the consul-ecs binary takes a large configuration file: https://github.com/hashicorp/consul-ecs/blob/0817f073c665c3933e9455f477b18500616e7c47/config/schema.json
  # the variable "consul_ecs_config" lets you specify the entire thing
  # however, arguments such as "upstreams" (below) can be used instead to 
  # target smaller parts of the config without specifying the entire thing: https://github.com/hashicorp/terraform-aws-consul-ecs/blob/3da977ed327ac9bf37a2083854152c2bb4e1ddac/modules/mesh-task/variables.tf#L303-L305
  upstreams = [
    {
      # Name of the CONSUL Service (not to be confused with the ECS Service)
      # This is specified by setting the "family" name for mesh task modules
      # The "family" will map both to the Consul Service and the ECS Task Definition
      # https://github.com/hashicorp/terraform-aws-consul-ecs/blob/main/modules/mesh-task/main.tf#L187
      # https://github.com/hashicorp/terraform-aws-consul-ecs/blob/v0.3.0/modules/mesh-task/variables.tf#L6-L10
      destinationName = "${local.project_tag}-payments"
      # This is the port that requests to this service will be sent to, and, the port that the proxy will be
      # listening on LOCALLY.
      # https://github.com/hashicorp/consul-ecs/blob/0817f073c665c3933e9455f477b18500616e7c47/config/schema.json#L326
      # the above link is the value this maps to
      localBindPort  = 1234
    },
    {
      # https://github.com/hashicorp/consul-ecs/blob/85755adb288055df92c1880d30f1861db771ca63/subcommand/mesh-init/command_test.go#L77
      # looks like upstreams need different local bind ports, which begs the question of what a localBindPort is even doing
      # I guess this is just what the service points to that the envoy listener goes through
      destinationName = "${local.project_tag}-messages"
      localBindPort  = 1235
    },
    {
      # this is good grounds for a sentinel rule, so that we always know what it is
      destinationName = "${local.project_tag}-images"
      localBindPort  = 1236
    }
  ]
  # join on the private IPs, much like the consul config "retry_join" argument
  retry_join = local.server_private_ips

  depends_on = [
    module.consul_acl_controller
  ]
}

# Payments Service API Task Definition
# --
# This represents one upstream service that the Client connects to
module "payments" {
  source            = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version           = "0.4.2"
  family = "${local.project_tag}-payments"

  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  container_definitions = [
    {
      name = "payments"
      image = "nicholasjackson/fake-service:v0.23.1"
      cpu = 0
      essential = true

      portMappings = [
        {
          containerPort = 9090
          hostPort = 9090
          protocol = "tcp"
        }
      ]

      logConfiguration = local.payments_log_configuration

      # Fake Service settings are set via Environment variables
      environment = [
        {
          name = "NAME" # Fake Service name
          value = "payments" 
        },
        {
          name = "MESSAGE" # Fake Service message to return
          value = "Hello from the Payments Service!"
        },
        {
          # this will need to change when/if the database is set up as an consul service
          name = "UPSTREAM_URIS" # Fake service upstream service to call to
          value = "http://${aws_instance.database.private_ip}:27017"
        }
      ]
    }
  ]

  acls = true
  acl_secret_name_prefix = local.project_tag
  consul_datacenter = var.consul_dc_1
  consul_server_ca_cert_arn = aws_secretsmanager_secret.consul_root_ca_cert.arn
  consul_client_token_secret_arn = module.consul_acl_controller.client_token_secret_arn
  gossip_key_secret_arn = aws_secretsmanager_secret.consul_gossip_key.arn
  port = "9090" 
  log_configuration = local.payments_sidecars_log_configuration
  tls = true
  retry_join = local.server_private_ips

  # below, if you wanted to override the consul service name
  # this defaults to what we specify as the Task Def Family
  # consul_service_name = "${local.project_tag}-payments"
  # consul_service_meta = {
  #   "version" = "v1"
  # }
  
  depends_on = [
    module.consul_acl_controller
  ]
}

# Messages Service API Task Definition
# --
# This represents another upstream service that the Client connects to
module "messages" {
  source            = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version           = "0.4.2"
  family = "${local.project_tag}-messages"

  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  container_definitions = [
    {
      name = "messages"
      image = "nicholasjackson/fake-service:v0.23.1"
      cpu = 0
      essential = true

      portMappings = [
        {
          containerPort = 9090
          hostPort = 9090
          protocol = "tcp"
        }
      ]

      logConfiguration = local.messages_log_configuration

      # Fake Service settings are set via Environment variables
      environment = [
        {
          name = "NAME" # Fake Service name
          value = "messages" 
        },
        {
          name = "MESSAGE" # Fake Service message to return
          value = "Hello from the Messages Service!"
        },
        {
          name = "UPSTREAM_URIS" # Fake service upstream service to call to
          value = "http://${aws_instance.database.private_ip}:27017"
        }
      ]
    }
  ]

  acls = true
  acl_secret_name_prefix = local.project_tag
  consul_datacenter = var.consul_dc_1
  consul_server_ca_cert_arn = aws_secretsmanager_secret.consul_root_ca_cert.arn
  consul_client_token_secret_arn = module.consul_acl_controller.client_token_secret_arn
  gossip_key_secret_arn = aws_secretsmanager_secret.consul_gossip_key.arn
  log_configuration = local.messages_sidecars_log_configuration
  port = "9090" 
  tls = true
  retry_join = local.server_private_ips

  depends_on = [
    module.consul_acl_controller
  ]
}
