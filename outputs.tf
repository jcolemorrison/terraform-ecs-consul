output "client_endpoint" {
  description = "The ALB endpoint for the Client application on Fargate."
  value = aws_lb.client_alb.dns_name
}

output "consul_server_ids" {
  value = aws_instance.consul_server[*].id
}

output "consul_bootstrap_token" {
  description = "The Consul Bootstrap token.  Do not share!"
  sensitive = true
  value = random_uuid.consul_bootstrap_token.result
}

output "consul_server_endpoint" {
  description = "The ALB endpoint for the Consul Servers."
  value = aws_lb.consul_server_alb.dns_name
}

output "applied_environment" {
  description = "the current workspace this project is responding to"
  value = terraform.workspace
}

output "project_tag" {
  description = "the tag used on all deployed resources and also as the service prefix"
  value = local.project_tag
}

output "project_test" {
  description = "the tag used on all deployed resources and also as the service prefix"
  value = "test"
}

output "project_region" {
  description = "region that the project is deployed to"
  value = var.aws_default_region
}

output "database_private_ip" {
  description = "private IP of the database"
  value = aws_instance.database.private_ip
}

output "consul_dc_name" {
  description = "name of the consul datacenter"
  value = var.consul_dc_1
}

output "consul_root_ca_cert_arn" {
  description = "ARN of the consul root ca certificate"
  value = aws_secretsmanager_secret.consul_root_ca_cert.arn
}

output "consul_client_token_secret_arn" {
  description = "ARN of the consul client token secret"
  value = module.consul_acl_controller.client_token_secret_arn
}

output "consul_gossip_key_arn" {
  description = "ARN of the consul gossip key"
  value = aws_secretsmanager_secret.consul_gossip_key.arn
}

output "consul_server_ips" {
  description = "array of the consul server IPs"
  value = local.server_private_ips
}

output "cluster_arn" {
  description = "ARN of the ECS Cluster"
  value = aws_ecs_cluster.main.arn
}

output "private_subnet_ids" {
  description = "Array of private subnet ids"
  value = aws_subnet.private.*.id
}

output "client_security_group_id" {
  description = "Client security group ID"
  value = aws_security_group.consul_client.id
}

output "upstream_security_group_id" {
  description = "Upstream security group ID"
  value = aws_security_group.ecs_upstream_service.id
}