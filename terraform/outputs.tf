output "elb_dns" {
  value = module.LoadBalancing.elb_dns_name
}
output "s3_bucket_arn" {
  value         = aws_s3_bucket.backend_s3_bucket.arn
  description   = "The ARN of S3 bucket"
}
output "dynamodb_table_arn" {
  value         = aws_dynamodb_table.terraform_state_lock.arn
  description   = "The ARN of the DynamoDB table used for state locking"
}