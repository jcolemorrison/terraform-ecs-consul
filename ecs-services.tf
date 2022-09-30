# User Facing Client Service
resource "aws_ecs_service" "client" {
  name = "${local.project_tag}-client"
  cluster = aws_ecs_cluster.main.arn
  task_definition = module.client.task_definition_arn
  desired_count = 1
  launch_type = "FARGATE"

  # this is only required if a service linked role for ECS isn't present in your account
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html
  # iam_role = aws_iam_role.service_linked_ecs_role.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.client_alb_targets.arn
    container_name = "client" # name from the above specified task definition's containers
    container_port = 9090
  }

  network_configuration {
    subnets = aws_subnet.private.*.id
    # defaults to the default VPC security group which allows all traffic from itself and all outbound traffic
    # instead, we define our own for each ECS service!
    security_groups = [aws_security_group.ecs_client_service.id, aws_security_group.consul_client.id]
    assign_public_ip = false
  }

  # THIS IS IMPORTANT on ALL SERVICES
  # this seems to add all sorts of tags TO THE TASK, in the format of: consul.hashicorp.com/<stuff>.  The ones it adds:
  # consul.hashicorp.com/module (i.e. terraform-aws-btb-ecs)
  # consul.hashicorp.com/service-name (i.e. terraform-aws-btb-client)
  # consul.hashicorp.com/mesh (i.e. true)
  # consul.hashicorp.com/module-version (i.e. 0.4.2)
  # AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-using-tags.html#tag-resources
  propagate_tags = "TASK_DEFINITION"
}

# Payments Service
resource "aws_ecs_service" "payments" {
  name = "${local.project_tag}-payments"
  cluster = aws_ecs_cluster.main.arn
  task_definition = module.payments.task_definition_arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = aws_subnet.private.*.id
    security_groups = [aws_security_group.ecs_upstream_service.id, aws_security_group.consul_client.id]
    assign_public_ip = false
  }

  propagate_tags = "TASK_DEFINITION"
}

# Messages Service
resource "aws_ecs_service" "messages" {
  name = "${local.project_tag}-messages"
  cluster = aws_ecs_cluster.main.arn
  task_definition = module.messages.task_definition_arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = aws_subnet.private.*.id
    security_groups = [aws_security_group.ecs_upstream_service.id, aws_security_group.consul_client.id]
    assign_public_ip = false
  }

  propagate_tags = "TASK_DEFINITION" 
}


# Consul ACL Controller Service
# https://registry.terraform.io/modules/hashicorp/consul-ecs/aws/latest/submodules/acl-controller?tab=inputs
module "consul_acl_controller" {
  source = "hashicorp/consul-ecs/aws//modules/acl-controller"
  version = "0.4.2"

  name_prefix = "${local.project_tag}"
  ecs_cluster_arn = aws_ecs_cluster.main.arn
  region = var.aws_default_region

  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.consul_bootstrap_token.arn
  consul_server_ca_cert_arn = aws_secretsmanager_secret.consul_root_ca_cert.arn

  # Point to a singular server IP.  Even if its not the leader, the request will be forwarded appropriately
  # this keeps us from using the public facing load balancer
  consul_server_http_addr = "https://${local.server_private_ips[0]}:8501"

  # the ACL controller module creates the required IAM role to allow logging
  log_configuration = local.acl_logs_configuration

  # mapped to an underlying `aws_ecs_service` resource, so its the same format
  security_groups = [aws_security_group.acl_controller.id, aws_security_group.consul_client.id]

  # mapped to an underlying `aws_ecs_service` resource, so its the same format
  subnets = aws_subnet.private.*.id

  depends_on = [
    aws_nat_gateway.nat,
    aws_instance.consul_server # https://github.com/hashicorp/terraform/issues/15285 should work, dsepite count
  ]
}