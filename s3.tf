data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "sorry_page_bucket" {
  bucket = "${var.project_name}-${var.env}-sorry-page-bucket"

  website {
    index_document = "sorry.html"
    error_document = "sorry.html"
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-sorry-page-bucket"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# SorryページのHTMLコンテンツを直接埋め込む
resource "aws_s3_bucket_object" "sorry_page" {
  bucket       = aws_s3_bucket.sorry_page_bucket.bucket
  key          = "sorry.html"
  content      = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Unavailable</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f8f8f8;
            font-family: Arial, sans-serif;
            text-align: center;
            color: #333;
        }
        .container {
            max-width: 600px;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 5px;
        }
        h1 {
            font-size: 2em;
            margin: 0 0 20px;
        }
        p {
            font-size: 1.2em;
            margin: 0 0 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Service Unavailable</h1>
        <p>We are currently experiencing technical difficulties. Please try again later.</p>
    </div>
</body>
</html>
EOF
  content_type = "text/html"
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.sorry_page_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.sorry_page_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_public_access_block.main,
  ]

  bucket = aws_s3_bucket.sorry_page_bucket.id
  acl    = "private"
}

# S3バケットポリシー
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.sorry_page_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "AWS" : [
            "${aws_cloudfront_origin_access_identity.static-www.iam_arn}"
          ]
        },
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.sorry_page_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "cloudwatch_logs" {
  bucket = "${var.project_name}-${var.env}-cloudwatch-logs"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-cloudwatch-logs"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

