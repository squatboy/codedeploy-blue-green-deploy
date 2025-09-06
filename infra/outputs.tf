output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions."
  value       = module.iam.github_actions_role_arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for CodeDeploy artifacts."
  value       = module.s3.s3_bucket_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = module.ecr.repository_url
}
