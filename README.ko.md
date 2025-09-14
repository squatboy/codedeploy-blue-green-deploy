# CI/CD Pipeline with Blue/Green Deployment on AWS 

이 프로젝트는 AWS에서 Terraform을 사용하여 인프라를 관리하고, GitHub Actions를 통해 CI/CD 파이프라인을 구축하여 Docker 컨테이너 기반 애플리케이션의 Blue/Green 배포를 구현합니다.

<img width="899" height="524" alt="image" src="https://github.com/user-attachments/assets/03964313-c856-4144-9ce6-b9dbe5e1c01f" />


### 주요 구성 요소

- **인프라 관리**: Terraform을 통해 VPC, IAM, S3, ALB, ASG, CodeDeploy 등의 AWS 리소스를 코드로 관리
- **CI/CD 파이프라인**: GitHub Actions를 사용하여 코드 푸시 시 자동으로 Docker 이미지 빌드, ECR 푸시, CodeDeploy 배포 실행
- **인증 방식**: OIDC (OpenID Connect)를 사용하여 GitHub에서 AWS로 안전한 인증
- **배포 전략**: Blue/Green 배포를 통해 무중단 배포 구현
- **애플리케이션**: 하나의 간단한 웹 애플리케이션 (Docker 컨테이너화) 을 예시로 사용

## 배포 및 테스트

### 요구 사항

- **Terraform**: [Terraform 공식 사이트](https://learn.hashicorp.com/tutorials/terraform/install-cli)를 참고하여 설치
- **AWS CLI**: [AWS CLI 설치 가이드](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)를 참고하여 설치하고, 사용할 AWS 계정의 자격 증명을 설정
- **GitHub 계정**: 코드를 푸시하고 GitHub Actions를 실행할 계정 필요


### 1. 인프라 배포 (Terraform)

Terraform을 사용하여 Blue/Green 배포에 필요한 모든 AWS 인프라(VPC, IAM, S3, ALB, ASG, CodeDeploy 등)를 생성합니다.

1.  **Terraform 변수 설정**

    ```bash
    git clone https://github.com/squatboy/codedeploy-blue-green-deploy.git
    cd codedeploy-blue-green-deploy/infra
    ```
    
    `infra` 디렉토리로 이동하여 `terraform.tfvars` 파일을 생성하고, 본인의 환경에 맞게 내용을 채웁니다.
    
    `terraform.tfvars` 파일 예시:
    ```hcl
    # terraform.tfvars
    github_repo    = "squatboy/codedeploy-blue-green-deploy"
    s3_bucket_name = "your-unique-codedeploy-artifact-bucket-name"
    ```
    - `github_repo`: 이 프로젝트를 푸시할 GitHub 리포지토리의 경로 (예: `squatboy/codedeploy-blue-green-deploy`).
    - `s3_bucket_name`: CodeDeploy가 배포 아티팩트를 저장할 S3 버킷의 이름. 전역적으로 고유해야 합니다.

2.  **Terraform 실행**

    `infra` 디렉토리에서 다음 명령어를 순서대로 실행

    ```bash
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```


### 2. GitHub 리포지토리 설정

1.  **GitHub 리포지토리 생성 및 코드 푸시**
    - `terraform.tfvars`에 입력했던 `github_repo` 경로와 동일한 GitHub 리포지토리를 생성
    - `codedeploy-blue-green-deploy` 프로젝트 전체를 해당 리포지토리로 푸시

2.  **GitHub Actions을 위한 Secrets 설정**

    GitHub 리포지토리의 `Settings > Secrets and variables > Actions` 메뉴로 이동하여 다음 Secrets을 추가합니다. `ap-northeast-2` 리전은 워크플로우에 하드코딩되어 있으므로 Secret으로 추가할 필요가 없습니다.

    - `AWS_ACCOUNT_ID`: AWS 계정의 12자리 숫자 ID (예: `123456789012`)
    - `S3_BUCKET_NAME`: `terraform.tfvars`에 입력했던 S3 버킷 이름과 동일한 값 입력


### 3. 첫 배포 실행 및 확인

코드를 `main` 브랜치에 푸시하면 `.github/workflows/cicd.yml` 워크플로우가 자동으로 실행됩니다.

1.  **GitHub Actions 워크플로우 확인**
    - 리포지토리의 `Actions` 탭으로 이동하여 워크플로우가 성공적으로 완료되었는지 확인합니다.
    - 워크플로우는 다음 단계를 수행합니다:
        1. AWS에 OIDC로 인증
        2. Docker 이미지 빌드 및 ECR에 푸시
        3. 애플리케이션 파일을 zip으로 압축 및 S3에 업로드
        4. CodeDeploy 배포 생성 및 시작

2.  **CodeDeploy 배포 상태 확인**
    - [AWS CodeDeploy 콘솔](https://console.aws.amazon.com/codedeploy/home)로 이동하여 배포가 성공적으로 완료되었는지 확인

3.  **애플리케이션 접속**
    - 웹 브라우저에서 Terraform 결과로 얻은 `alb_dns_name` 주소로 접속
    - 예시 어플리케이션의 메세지 "Hello, World! This is version 1.0" 표시 확인


### 4. Blue/Green 배포 테스트

이제 애플리케이션 코드를 수정하여 새로운 버전을 배포하고, 트래픽이 자동으로 전환되는지 확인합니다.

1.  **애플리케이션 코드 수정**
    - `app/index.js` 파일의 버전 정보를 수정
    - 예시
      ```javascript
      // app/index.js
      // ...
      const version = '2.0'; // 1.0 -> 2.0
      // ...
      ```

2.  **코드 변경사항 푸시**
    - 변경된 코드를 `main` 브랜치에 커밋하고 푸시
      ```bash
      git add app/index.js
      git commit -m "Update to version 2.0"
      git push origin main
      ```

3.  **Blue/Green 배포 과정 모니터링**
    - 코드가 푸시되면 새로운 GitHub Actions 워크플로우가 실행되고, CodeDeploy 배포 시작
    - AWS CodeDeploy 콘솔에서 배포 상태를 확인
    - **Step 1: Provisioning new instances (Green environment)**: CodeDeploy가 새로운 Auto Scaling Group("Green" 환경)을 생성 및 새 버전의 애플리케이션을 배포
    - **Step 2: Rerouting traffic**: Green 환경의 인스턴스가 정상 상태가 되면, ALB 리스너가 트래픽을 Blue 환경에서 Green 환경으로 전환
    - **Step 3: Terminating old instances**: 트래픽 전환 후 설정된 대기 시간이 지나면, 이전 버전의 인스턴스("Blue" 환경) 종료

        <img width="1472" height="584" alt="라우팅_전환2" src="https://github.com/user-attachments/assets/ec94a81a-df5d-4874-b46b-027139d4465c" />

4.  **배포 결과 확인**
    - 배포의 "Step 2"가 진행되는 동안 웹 브라우저에서 `alb_dns_name` 주소를 새로고침하면서 "Hello, World! This is version 2.0" 메시지로 바뀌는 것을 확인
      > 이는 무중단으로 트래픽이 신규 버전으로 전환되었음을 의미함.
      <img width="1369" height="584" alt="codedeploy-2단계" src="https://github.com/user-attachments/assets/08469129-d526-460b-9031-d08b617bccdc" />


### 5. 리소스 정리

테스트가 완료된 후에는 불필요한 비용이 발생하지 않도록 생성했던 모든 AWS 리소스를 삭제합니다.

1.  **Terraform 리소스 삭제**
    - `infra` 디렉토리에서 다음 명령어를 실행

      ```bash
      terraform destroy -auto-approve
      ```

2.  **S3 버킷 확인**
    - `terraform destroy`는 일반적으로 ECR과 비어있지 않은 S3 버킷을 삭제하지 못하므로, 콘솔로 이동하여 수동으로 삭제하면 됩니다.

3.  **GitHub 리포지토리 정리**
    - 생성했던 GitHub 리포지토리와 Secrets를 삭제합니다.
