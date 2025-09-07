output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "codedeploy_service_role_arn" {
  value = aws_iam_role.codedeploy.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
