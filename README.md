# AWS CodePipeline for and Elastic Beanstalk deployment with Terraform


This repository contains Terraform configurations to set up a complete CI/CD pipeline using AWS CodePipeline, CodeBuild, and Elastic Beanstalk. The pipeline fetches source code from an S3 bucket, builds it using CodeBuild, and deploys it to an Elastic Beanstalk environment. 

The setup includes the following key components:

- **S3 Bucket:** An S3 bucket is configured to store the source code and build artifacts. This bucket serves as the primary source for CodePipeline and storage for build outputs.
- **IAM Roles and Policies:** The necessary IAM roles and policies are created to provide CodePipeline, CodeBuild, and other AWS services the permissions required to interact with each other securely. This includes roles for CodeBuild to access S3 and CloudWatch and roles for CodePipeline to manage the entire pipeline process.
- **CodeBuild Project:** A CodeBuild project is defined with all necessary environment settings, including the compute type, build specifications, and artifact locations. This project is responsible for compiling and packaging the source code.
- **CodePipeline Configuration:** The CodePipeline is set up with multiple stages:
  - **Source Stage:** Fetches the source code from the S3 bucket.
  - **Build Stage:** Uses CodeBuild to compile and package the application.
  - **Deploy Stage:** Deploys the built application to an Elastic Beanstalk environment.

The CI/CD pipeline automates the entire process from code check-in to deployment, ensuring a consistent and reliable deployment workflow.

## Prerequisites

- Terraform v1.0 or later
- AWS CLI configured with appropriate permissions
- An S3 bucket for CodePipeline source artifacts
- Elastic Beanstalk application and environment

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
- **codebuild_role_arn:** ARN of the IAM role for CodeBuild.
- **codepipeline_role_arn:** ARN of the IAM role for CodePipeline.
- **codebuild_project_name:** Name of the CodeBuild project.
- **pipeline_name:** Name of the CodePipeline.




