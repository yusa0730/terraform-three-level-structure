resource "aws_cloudwatch_log_group" "ecs_web" {
  name              = "/ecs/${var.env}/web"
  retention_in_days = 14

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-ecs-web"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.env}/app"
  retention_in_days = 14

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-ecs-app"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "redis_engine_logs" {
  name = "/redis/${var.env}/engine-logs"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-redis-engine-logs"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "redis_slow_logs" {
  name = "/redis/${var.env}/slow-logs"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-redis-slow-logs"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "kinesis" {
  name = "/kinesis/${var.env}"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-kinesis-logs"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

