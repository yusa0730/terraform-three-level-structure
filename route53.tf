# resource "aws_route53_zone" "main" {
#   name          = var.domain
#   force_destroy = false

#   tags = {
#     Name      = "${var.project_name}-${var.env}-route53-domain"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

data "aws_route53_zone" "main" {
  name = "${var.domain}."
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.id
  name    = "${var.env}-elb.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.main.id
  name    = "${var.env}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}

