# lambda dist

resource "aws_s3_bucket" "lambda_dist" {
  bucket = "${var.prefix}-lambda-dist"
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "private-lambda" {
  bucket = aws_s3_bucket.lambda_dist.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "private-lambda1" {
  bucket                  = aws_s3_bucket.lambda_dist.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning-lambda" {
  bucket = aws_s3_bucket.lambda_dist.id
  versioning_configuration {
    status = "Enabled"
  }
}

# data

resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.prefix}-data"
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "private-data" {
  bucket = aws_s3_bucket.data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "private-data1" {
  bucket                  = aws_s3_bucket.data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning-data" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# website

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.website_bucket
  tags   = var.tags
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::www2.atacar.net/*"
      }
    ]
  }
EOF
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.website_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "contactus.html"
  }
}
