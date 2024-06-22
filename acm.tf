# resource "aws_acm_certificate" "main" {
#   domain_name       = "*.${var.domain}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [aws_route53_zone.main]

#   tags = {
#     Name      = "${var.project_name}-${var.env}-acm-certificate"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_acm_certificate" "virginia" {
#   provider = aws.virginia

#   domain_name = "*.${var.domain}"

#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [aws_route53_zone.main]

#   tags = {
#     Name      = "${var.project_name}-${var.env}-acm-certificate-virginia"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_route53_record" "acm_dns_resolve" {
#   for_each = {
#     for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }

#   allow_overwrite = true
#   zone_id         = aws_route53_zone.main.zone_id
#   name            = each.value.name
#   type            = each.value.type
#   ttl             = 600
#   records         = [each.value.record]
# }

# resource "aws_acm_certificate_validation" "main" {
#   certificate_arn         = aws_acm_certificate.main.arn
#   validation_record_fqdns = [for record in aws_route53_record.acm_dns_resolve : record.fqdn]
# }

data "aws_acm_certificate" "main" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]

  most_recent = true
}

data "aws_acm_certificate" "virginia" {
  provider = aws.virginia

  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]

  most_recent = true
}

