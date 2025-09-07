variable "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "blue_target_group_arn" {
  description = "ARN of the blue target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
