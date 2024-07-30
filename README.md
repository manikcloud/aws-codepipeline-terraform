# AWS CodePipeline for and Elastic Beanstalk deployment with Terraform

This repository contains Terraform configurations to set up an AWS CodePipeline with integrated CodeBuild and Elastic Beanstalk deployment.

## Prerequisites

- Terraform v1.0 or later
- AWS CLI configured with appropriate permissions
- An S3 bucket for CodePipeline source artifacts
- Elastic Beanstalk application and environment

## Configuration

Before deploying the Terraform configurations, ensure you have the following details:

- Desired AWS region
- S3 bucket name for CodeBuild artifacts
- Elastic Beanstalk application name
- Elastic Beanstalk environment name

## Usage

1. **Clone the Repository:**

    ```sh
    git clone https://github.com/manikcloud/aws-codepipeline-terraform.git
    cd aws-codepipeline-terraform
    ```

2. **Update the Terraform Configuration:**

    Modify the Terraform files to match your environment. Update the placeholders for S3 bucket name, Elastic Beanstalk application, and environment names.

3. **Initialize Terraform:**

    ```sh
    terraform init
    ```

4. **Apply the Terraform Configuration:**

    ```sh
    terraform apply
    ```

    Confirm the apply with `yes` when prompted.

## Terraform Configuration

### AWS Provider

```hcl
provider "aws" {
  region = "us-east-1" # Change to your desired region
}
## Overview of Terraform Configuration

### AWS Provider

Defines the AWS region for the resources.

### S3 Bucket for CodeBuild Artifacts

Creates an S3 bucket to store CodeBuild artifacts.

### IAM Roles and Policies

- **CodeBuild Role:** Allows CodeBuild to interact with S3 and CloudWatch.
- **CodePipeline Role:** Allows CodePipeline to access S3, CodeBuild, and Elastic Beanstalk.

### CodeBuild Project

Defines a CodeBuild project with the necessary environment settings and build specifications.

### CodePipeline Configuration

Defines a pipeline with three stages:
1. **Source:** Fetches source code from S3.
2. **Build:** Builds the code using CodeBuild.
3. **Deploy:** Deploys the built code to Elastic Beanstalk.

## Outputs

- **bucket_name:** Name of the S3 bucket used by CodeBuild.

```
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "my-codebuild-bucket-12345" # Change to your desired bucket name
  acl    = "private"
}

```
- **codebuild_role_arn:** ARN of the IAM role for CodeBuild.
- **codepipeline_role_arn:** ARN of the IAM role for CodePipeline.
- **codebuild_project_name:** Name of the CodeBuild project.
- **pipeline_name:** Name of the CodePipeline.






