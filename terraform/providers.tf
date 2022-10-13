provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    bucket  = "atacar-terraform"
    key     = "terraform.tfstate"
    encrypt = true
    region  = "us-east-1" 
    profile = "default"
  }
}
