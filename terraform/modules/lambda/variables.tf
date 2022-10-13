variable "prefix" {
    description = "Prefix string for organizing resources"
    type = string
}

variable "tags" {
  description = "Common tags for organizing resources"
  type = map(string)
}

variable "dist_bucket" {
    description = "S3 bucket for build artifacts"
    type = string
}

variable "admin_password" {
    description = "Admin module password"
    type = string
}
