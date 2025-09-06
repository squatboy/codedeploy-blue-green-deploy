variable "codedeploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  type        = string
}

variable "listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue target group"
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green target group"
  type        = string
}
