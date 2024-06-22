# ECR
data "aws_ecr_repository" "nginx" {
  name = "${var.project_name}-${var.env}-ecr-nginx"
}

data "aws_ecr_repository" "php-fpm" {
  name = "${var.project_name}-${var.env}-ecr-php-fpm"
}

# resource "aws_ecr_repository" "nginx" {
#   name                 = "${var.project_name}-${var.env}-ecr-nginx"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = {
#     Name      = "${var.project_name}-${var.env}-ecr-nginx"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_ecr_repository" "php-fpm" {
#   name                 = "${var.project_name}-${var.env}-ecr-php-fpm"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = {
#     Name      = "${var.project_name}-${var.env}-ecr-php-fpm"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }
