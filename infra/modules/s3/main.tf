# S3 Bucket for CodeDeploy artifacts
resource "aws_s3_bucket" "codedeploy_artifacts" {
  bucket = var.s3_bucket_name
}
