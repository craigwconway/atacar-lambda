output "lambda_dist_bucket" {
  value = aws_s3_bucket.lambda_dist.bucket
}

output "data_bucket" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "website_bucket" {
  value = aws_s3_bucket.website_bucket.bucket
}
