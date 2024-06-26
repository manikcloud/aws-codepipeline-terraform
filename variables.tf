variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "Dev"
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}
