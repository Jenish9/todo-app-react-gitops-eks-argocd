resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "MyAppBucket"
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "app_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "MyAppTable"
    Environment = var.environment
  }
}