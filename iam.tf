resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.env}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-task-execution-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "ecs_policy" {
  name = "${var.project_name}-${var.env}-ecs-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "${aws_cloudwatch_log_group.ecs_web.arn}",
          "${aws_cloudwatch_log_group.ecs_app.arn}",
          "${aws_cloudwatch_log_group.ecs_web.arn}:*",
          "${aws_cloudwatch_log_group.ecs_app.arn}:*"
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-policy"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  policy_arn = aws_iam_policy.ecs_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_role" "firehose_delivery_role" {
  name = "${var.project_name}-${var.env}-firehose-delivery-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-firehose-delivery-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "firehose_delivery_role_policy" {
  name = "${var.project_name}-${var.env}-firehose-delivery-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.cloudwatch_logs.arn}",
          "${aws_s3_bucket.cloudwatch_logs.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-firehose-delivery-role-policy"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "firehose_delivery_role_attachment" {
  policy_arn = aws_iam_policy.firehose_delivery_role_policy.arn
  role       = aws_iam_role.firehose_delivery_role.name
}

resource "aws_iam_role" "kinesis_basic_role" {
  name = "${var.project_name}-${var.env}-kinesis-basic-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.ap-northeast-1.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-kinesis-basic-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "kinesis_basic_role_policy" {
  name = "${var.project_name}-${var.env}-kinesis-basic-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = [
          "${aws_kinesis_firehose_delivery_stream.web_logs_to_s3.arn}",
          "${aws_kinesis_firehose_delivery_stream.app_logs_to_s3.arn}",
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-kinesis-basic-role-policy"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "kinesis_basic_role_attachment" {
  policy_arn = aws_iam_policy.kinesis_basic_role_policy.arn
  role       = aws_iam_role.kinesis_basic_role.name
}


resource "aws_iam_role" "ecs_autoscale_role" {
  name = "${var.project_name}-${var.env}-ecs-autoscale-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-autoscale-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "ecs_autoscale_role_policy" {
  name = "${var.project_name}-${var.env}-ecs-autoscale-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-autoscale-role-policy"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_attachment" {
  policy_arn = aws_iam_policy.ecs_autoscale_role_policy.arn
  role       = aws_iam_role.ecs_autoscale_role.name
}

