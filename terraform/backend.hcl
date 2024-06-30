bucket = "tf-${local.resource_name}-backend-bucket-9dsd31"
region = local.region
dynamodb_table = "tf-${local.resource_name}-backend-lock"
encrypt = true
