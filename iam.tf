# ECS Task IAM Role
resource "aws_iam_role" "task_execution_role" {
  name_prefix = "${local.project_tag}-te-role"
  description = "Task execution role for the ECS task definitions"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_trust_policy.json
}

## ECS Task Role Trust Policy
data "aws_iam_policy_document" "ecs_task_exec_trust_policy" {
  statement {
    sid = "ECSTaskAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

## CloudWatch Logging Permissions Policy
data "aws_iam_policy_document" "cloudwatch_logging_policy" {
  statement {
    sid = "AllowPutLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

## CloudWatch Logging Permissions Policy Attachment
resource "aws_iam_role_policy" "cloudwatch_logging" {
  name_prefix = "${local.project_tag}-cw-logging"
  role = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.cloudwatch_logging_policy.json
}

# Consul Instance Role
resource "aws_iam_role" "consul_instance" {
  name_prefix        = "${local.project_tag}-role-"
  assume_role_policy = data.aws_iam_policy_document.instance_trust_policy.json
}

## Consul Instance Trust Policy
data "aws_iam_policy_document" "instance_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

## Consul Instance Permissions Policy
data "aws_iam_policy_document" "instance_permissions_policy" {
  statement {
    sid    = "DescribeInstances" # change this to describe instances...
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = [
      "*"
    ]
  }
}

## Consul Instance Role <> Policy Attachment
resource "aws_iam_role_policy" "consul_instance_policy" {
  name_prefix = "${local.project_tag}-instance-policy-"
  role        = aws_iam_role.consul_instance.id
  policy      = data.aws_iam_policy_document.instance_permissions_policy.json
}

## Consul Instance Profile <> Role Attachment
resource "aws_iam_instance_profile" "consul_instance_profile" {
  name_prefix = "${local.project_tag}-instance-profile-"
  role        = aws_iam_role.consul_instance.name
}