locals {
  lambda_path = "../lambda"
  temp_path   = "tmp/"
  layer_path = "python/lib/python3.8/site-packages/"
  runtime = "python3.8"
}

# IAM

resource "aws_iam_role" "iam_role" {
  name = "${var.prefix}_lambda_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_role" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Dependencies

locals {
  dependencies_hash = filemd5("${local.lambda_path}/requirements.txt")
}

resource "null_resource" "dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${local.lambda_path}/requirements.txt -t ${local.temp_path}${local.layer_path} --upgrade"
  }
  triggers = {
    dependencies_versions = filemd5("${local.lambda_path}/requirements.txt")
  }
}

# Common Code Layer

locals {
  common_code_hash = md5(join("", [for f in fileset("${local.lambda_path}/common", "**"): filemd5("${local.lambda_path}/common/${f}")]))
}

resource "null_resource" "common_src" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.temp_path}${local.layer_path} && cp -r ${local.lambda_path}/common ${local.temp_path}${local.layer_path}"
  }
  triggers = {
    hash = local.common_code_hash
  }
}

locals {
  common_layer_hash = md5("${local.dependencies_hash}-${local.common_code_hash}")
  common_layer_package = "dist/${var.prefix}-common-${local.common_layer_hash}.zip"
}

data "archive_file" "common_layer_zip" {
  source_dir = local.temp_path
  output_path = local.common_layer_package
  output_file_mode = "0644"
  type = "zip"
  excludes    = [
    "__pycache__",
  ]
  depends_on = [null_resource.dependencies, null_resource.common_src]
}

resource "aws_s3_object" "common_layer_s3_artifact" {
  bucket = var.dist_bucket
  key    = "${var.prefix}_common_layer.zip"
  source = data.archive_file.common_layer_zip.output_path
  etag = local.common_layer_hash
}

resource "aws_lambda_layer_version" "lambda_layer_common" {
  s3_bucket = var.dist_bucket
  s3_key = aws_s3_object.common_layer_s3_artifact.key
  layer_name = "${var.prefix}_common"
  source_code_hash = local.common_layer_hash
  compatible_runtimes = [local.runtime]
}

# Lambda Functions

data "archive_file" "lambda_zip" {
  source_dir = "${local.lambda_path}/admin"
  output_path = "dist/${var.prefix}-admin.zip"
  output_file_mode = "0644"
  type = "zip"
  excludes    = [
    "__pycache__",
  ]
}

resource "aws_s3_object" "lambda_s3_artifact" {
  bucket = var.dist_bucket
  key    = "${var.prefix}-admin.zip"
  source = data.archive_file.lambda_zip.output_path
  etag = md5(data.archive_file.lambda_zip.output_path)
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket = var.dist_bucket
  s3_key = aws_s3_object.lambda_s3_artifact.key
  function_name = "${var.prefix}_admin"
  handler = "admin.lambda_handler"
  role = aws_iam_role.iam_role.arn
  runtime = local.runtime
  layers = [aws_lambda_layer_version.lambda_layer_common.arn]
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags = var.tags
  timeout = 30
  environment {
    variables = {
      ADMIN_PASSWORD = var.admin_password
      WEBSITE_BUCKET = "www2.atacar.net"
      DATA_BUCKET = "${var.prefix}-data"
    }
  }
}

# Logging

resource "aws_cloudwatch_log_group" "lambda_logging" {
  name = "/aws/lambda/${var.prefix}-admin"
  retention_in_days = 7
  tags = var.tags
}
