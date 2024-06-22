resource "aws_kinesis_firehose_delivery_stream" "web_logs_to_s3" {
  name        = "${var.project_name}-${var.env}-web-logs-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_delivery_role.arn
    bucket_arn         = aws_s3_bucket.cloudwatch_logs.arn
    buffer_size        = 1
    buffer_interval    = 60
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis.id
      log_stream_name = "WebDestinationDelivery"
    }
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-web-logs-firehose"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "app_logs_to_s3" {
  name        = "${var.project_name}-${var.env}-app-logs-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_delivery_role.arn
    bucket_arn         = aws_s3_bucket.cloudwatch_logs.arn
    buffer_size        = 1
    buffer_interval    = 60
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis.id
      log_stream_name = "AppDestinationDelivery"
    }
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-app-logs-firehose"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

