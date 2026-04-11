output "dynamodb_table_arn" {
  value = aws_dynamodb_table.app_table.arn
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.app_bucket.arn
}