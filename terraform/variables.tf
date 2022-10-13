variable "prefix" {
  description = "Prefix string for naming resources"
  type        = string
  default     = "atacar"
}

variable "tags" {
  description = "Common tags for organizing resources"
  type        = map(string)
  default = {
    project     = "atacar"
    environment = "production"
    provisioner = "terraform"
  }
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "admin_password" {
  type    = string
  default = "password"
}

variable "website_bucket" {
  type    = string
  default = "www2.atacar.net"
}
