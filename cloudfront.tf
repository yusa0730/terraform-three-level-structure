# Create a CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "static-www" {
  comment = "Terraform Test"
}

# CloudFront
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "https connection to alb"
  price_class     = "PriceClass_All"

  origin {
    domain_name = aws_route53_record.main.fqdn
    origin_id   = aws_lb.main.id

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      http_port              = 80
      https_port             = 443
    }
  }

  origin {
    domain_name = aws_s3_bucket.sorry_page_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.sorry_page_bucket.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static-www.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    target_origin_id       = aws_lb.main.id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  ordered_cache_behavior {
    path_pattern           = "/sorry.html"
    target_origin_id       = aws_s3_bucket.sorry_page_bucket.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 500
    response_page_path    = "/sorry.html"
    response_code         = 200
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 502
    response_page_path    = "/sorry.html"
    response_code         = 200
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 503
    response_page_path    = "/sorry.html"
    response_code         = 200
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 504
    response_page_path    = "/sorry.html"
    response_code         = 200
    error_caching_min_ttl = 30
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["${var.env}.${var.domain}"]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.virginia.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }
}

