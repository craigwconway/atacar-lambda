terraform{
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0.2"
    }
  }
}

module "s3" {
  source = "./modules/s3"
  prefix = var.prefix
  tags = var.tags
  website_bucket = var.website_bucket
}

module "lambda" {
  source = "./modules/lambda"
  prefix = var.prefix
  tags = var.tags
  admin_password = var.admin_password
  dist_bucket = module.s3.lambda_dist_bucket
}
