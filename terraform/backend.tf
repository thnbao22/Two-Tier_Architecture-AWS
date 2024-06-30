terraform {
  backend "s3" {
    key            = "statefile/terraform.tfstate"
  }
}

resource "aws_s3_bucket" "backend_s3_bucket" {
  bucket = "tf-${local.resource_name}-backend-bucket-9dsd31"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}
# Enable versioning so you can see the full version of your state file
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.backend_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
# By default, enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.backend_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# Explicitly block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                    = aws_s3_bucket.backend_s3_bucket.id
  # Block public ACLs for this bucket
  block_public_acls         = true
  # Block public policy for this bucket
  block_public_policy       = true
  # Ignore public ACLs for this bucket
  ignore_public_acls        = true
  # Restrict public access to this bucket
  restrict_public_buckets   = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "tf-${local.resource_name}-backend-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

