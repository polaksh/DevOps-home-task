provider "aws" {
  # alias                       = "task"
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2        = "http://localstack:4566"
    s3         = "http://localstack:4566"
    rds        = "http://localstack:4566"
    iam        = "http://localstack:4566"
    cloudwatch = "http://localstack:4566"
    lambda     = "http://localstack:4566"
    apigateway = "http://localstack:4566"
  }
}
