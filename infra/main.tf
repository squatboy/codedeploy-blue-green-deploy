module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "iam" {
  source      = "./modules/iam"
  github_repo = var.github_repo
}

module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = var.s3_bucket_name
}

module "ecr" {
  source = "./modules/ecr"
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "asg" {
  source                    = "./modules/asg"
  ec2_instance_profile_name = module.iam.ec2_instance_profile_name
  public_subnet_ids         = module.vpc.public_subnet_ids
  blue_target_group_arn     = module.alb.blue_target_group_arn
  alb_security_group_id     = module.alb.alb_security_group_id
  vpc_id                    = module.vpc.vpc_id
}

module "codedeploy" {
  source                      = "./modules/codedeploy"
  codedeploy_service_role_arn = module.iam.codedeploy_service_role_arn
  blue_target_group_name      = module.alb.blue_target_group_name
}