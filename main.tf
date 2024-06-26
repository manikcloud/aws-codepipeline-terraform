provider "aws" {
  region = "us-east-1" # Change to your desired region
}

resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "my-codebuild-bucket-12345" # Change to your desired bucket name
  acl    = "private"
  
  tags = {
    Name        = "CodeBuildBucket"
    Environment = "Dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.codebuild_bucket.id
}
