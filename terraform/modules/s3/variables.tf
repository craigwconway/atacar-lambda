variable "prefix" {
    description = "Prefix string for organizing resources"
    type = string
}

variable "tags" {
  description = "Common tags for organizing resources"
  type = map(string)
}

variable "website_bucket" {
  description = "Website bucket name"
  type = string
}
