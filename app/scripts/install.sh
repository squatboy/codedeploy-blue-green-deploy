#!/bin/bash
# Install Docker if not already installed
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

# Login to ECR
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_REPO_URL

# Stop and remove existing container
docker stop blue-green-app || true
docker rm blue-green-app || true
