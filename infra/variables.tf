variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CodeDeploy artifacts"
  type        = string
}
