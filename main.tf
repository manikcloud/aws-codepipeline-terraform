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
    buildspec = <<EOF
    version: 0.2

    phases:
    build:
        commands:
        - mkdir .ebextensions
        - cd .ebextensions
        - aws s3 cp s3://pldt-nprd-smart-appcode-repo/ebs/NETFLIX/.ebextensions/ . --recursive
        - cd ..
        - ls -lart

    artifacts:
    files:
        - '**/*'
    EOF
  
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


#### codepipeline iam role ####

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cross_account_policy" {
  name   = "CrossAccountPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = "sts:AssumeRole",
            Resource = [
                "arn:aws:iam::1234567890:role/*"
            ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cross_account_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.cross_account_policy.arn
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "codepipeline-policy"
  description = "Policy for CodePipeline to access S3, CodeBuild, and EBS"

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
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticbeanstalk:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}


###### codepipeline ################

resource "aws_codepipeline" "pipeline" {
  name     = "my-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket = aws_s3_bucket.codebuild_bucket.bucket
        S3ObjectKey = "source.zip" # Update this as needed
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ElasticBeanstalk"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ApplicationName = "my-ebs-application" # Replace with your EBS application name
        EnvironmentName = "my-ebs-environment" # Replace with your EBS environment name
      }
    }
  }

  tags = {
    Name        = "CodePipeline"
    Environment = "Dev"
  }
}

output "pipeline_name" {
  value = aws_codepipeline.pipeline.name
}
