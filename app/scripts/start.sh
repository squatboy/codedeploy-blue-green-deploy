#!/bin/bash
# Load environment variables
source /home/ec2-user/app/.env

cd /home/ec2-user/app

# Pull the latest image
docker pull $ECR_REPO_URL:latest

# Run the container
docker run -d --name blue-green-app -p 3000:3000 $ECR_REPO_URL:latest
