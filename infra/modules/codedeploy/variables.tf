variable "codedeploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue target group"
  type        = string
}

variable "blue_asg_name" {
  description = "Name of the blue Auto Scaling Group"
  type        = string
}
