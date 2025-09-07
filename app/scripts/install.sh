#!/bin/bash
set -e -x

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_REPO_URL

# 기존 컨테이너 중지 및 삭제 (오류가 나도 계속 진행)
docker stop blue-green-app || true
docker rm blue-green-app || true

# 최신 Docker 이미지 가져오기
docker pull $ECR_REPO_URL:latest

# 새 컨테이너 실행
docker run -d --name blue-green-app -p 3000:3000 $ECR_REPO_URL:latest