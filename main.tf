provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

// Terraform Cloudの場合は以下不要
terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51"
    }
  }
  backend "s3" {
    bucket = "infrastructure-lesson-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

