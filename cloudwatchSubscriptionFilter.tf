resource "aws_cloudwatch_log_subscription_filter" "ecs_web" {
  name            = "${var.project_name}-${var.env}-web-logs-subscription-filter"
  log_group_name  = aws_cloudwatch_log_group.ecs_web.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.web_logs_to_s3.arn
  role_arn        = aws_iam_role.kinesis_basic_role.arn

  depends_on = [
    aws_cloudwatch_log_group.ecs_web
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "ecs_app" {
  name            = "${var.project_name}-${var.env}-app-logs-subscription-filter"
  log_group_name  = aws_cloudwatch_log_group.ecs_app.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.app_logs_to_s3.arn
  role_arn        = aws_iam_role.kinesis_basic_role.arn

  depends_on = [
    aws_cloudwatch_log_group.ecs_app
  ]
}

