# AWS Provider Default Settings
variable "aws_default_region" {
  type        = string
  description = "The default region that all resources will be deployed into."
  default     = "us-east-1"
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags added to all AWS resources."
  default = {
    Project = "tf-ecs-consul"
  }
}

# AWS VPC Settings and Options
variable "vpc_cidr" {
  type        = string
  description = "Cidr block for the VPC.  Using a /16 or /20 Subnet Mask is recommended."
  default     = "10.255.0.0/20"
}

variable "vpc_instance_tenancy" {
  type        = string
  description = "Tenancy for instances launched into the VPC."
  default     = "default"
}

variable "vpc_public_subnet_count" {
  type        = number
  description = "The number of public subnets to create.  Cannot exceed the number of AZs in your selected region.  2 is more than enough."
  default     = 3
}

variable "vpc_private_subnet_count" {
  type        = number
  description = "The number of private subnets to create.  Cannot exceed the number of AZs in your selected region."
  default     = 3
}

variable "database_private_ip" {
  type = string
  description = "Locked private IP for the database."
  default = "10.255.3.253"
}

variable "ec2_key_pair_name" {
  description = "An existing EC2 key pair used to access the bastion server."
  type        = string
}

# Consul Server Settings
variable "consul_server_count" {
  type        = number
  description = "The number of Consul Servers to create.  Decrementing this value once your cluster is up can cause problem."
  default     = 3
}

variable "consul_dc_1" {
  type = string
  description = "Name for the consul datacenter."
  default = "dc1"
}

variable "consul_server_allowed_cidr_blocks" {
  type = list(string)
  description = "List of valid IPv4 CIDR blocks that can access the consul servers from the public internet."
  default     = ["0.0.0.0/0"]
}

variable "consul_server_allowed_cidr_blocks_ipv6" {
  type        = list(string)
  description = "List of valid IPv6 CIDR blocks that can access the consul servers from the public internet."
  default     = ["::/0"]
}

variable "tfc_organization" {
  description = "Name of the Terraform Cloud Organization. Set in TFC Workspace Variables or via Variables File."
  type = string
}

variable "tfc_workspace_tag" {
  description = "Name of the Terraform Cloud Workspace Tag.  All created workspaces share this tag. Set in TFC Workspace Variables or via Variables File"
  type = string
}