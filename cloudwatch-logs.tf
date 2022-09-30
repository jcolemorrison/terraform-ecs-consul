resource "aws_cloudwatch_log_group" "client" {
  name_prefix = "${local.project_tag}-client-"
}

resource "aws_cloudwatch_log_group" "client_sidecars" {
  name_prefix = "${local.project_tag}-client-sidecars-"
}

resource "aws_cloudwatch_log_group" "payments" {
  name_prefix = "${local.project_tag}-payments-"
}

resource "aws_cloudwatch_log_group" "payments_sidecars" {
  name_prefix = "${local.project_tag}-payments-sidecars-"
}

resource "aws_cloudwatch_log_group" "messages" {
  name_prefix = "${local.project_tag}-messages-"
}

resource "aws_cloudwatch_log_group" "messages_sidecars" {
  name_prefix = "${local.project_tag}-messages-sidecars-"
}

resource "aws_cloudwatch_log_group" "acl" {
  name_prefix = "${local.project_tag}-acl-"
}

locals {
  acl_logs_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.acl.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-acl-"
    }
  }
  client_logs_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.client.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-client"
    }
  }
  client_sidecars_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.client_sidecars.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-client-sidecars-"
    }
  }
  payments_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.payments.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-payments-"
    }
  }
  payments_sidecars_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.payments_sidecars.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-payments-sidecars-"
    }
  }
  messages_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.messages.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-messages"
    }
  }
  messages_sidecars_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.messages_sidecars.name
      awslogs-region        = var.aws_default_region
      awslogs-stream-prefix = "${local.project_tag}-messages-sidecars-"
    }
  }
}