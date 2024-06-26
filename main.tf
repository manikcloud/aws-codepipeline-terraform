provider "aws" {
  region = "us-east-1" # Change to your desired region
}

resource "aws_s3_bucket_acl" "codebuild_bucket" {
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
###########

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  description = "Policy for CodeBuild to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.codebuild_bucket.arn,
          "${aws_s3_bucket.codebuild_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

########### Code Build ##########


resource "aws_codebuild_project" "codebuild_project" {
  name          = "my-codebuild-project"
  description   = "My CodeBuild project"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
    packaging = "ZIP"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "S3"
    location  = "${aws_s3_bucket.codebuild_bucket.bucket}/source.zip" # Update this as needed
  }

  cache {
    type = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
  }

  tags = {
    Name        = "CodeBuildProject"
    Environment = "Dev"
  }
}

output "codebuild_project_name" {
  value = aws_codebuild_project.codebuild_project.name
}
