# CI/CD Pipeline with Blue/Green Deployment on AWS

This project implements Blue/Green deployment of Docker container-based applications using Terraform to manage infrastructure on AWS and GitHub Actions to build a CI/CD pipeline.

<img width="899" height="524" alt="image" src="https://github.com/user-attachments/assets/03964313-c856-4144-9ce6-b9dbe5e1c01f" />


### Key Components

- **Infrastructure Management**: Manage AWS resources such as VPC, IAM, S3, ALB, ASG, CodeDeploy as code using Terraform
- **CI/CD Pipeline**: Automatically build Docker images, push to ECR, and execute CodeDeploy deployments when code is pushed using GitHub Actions
- **Authentication Method**: Use OIDC (OpenID Connect) for secure authentication from GitHub to AWS
- **Deployment Strategy**: Implement zero-downtime deployment through Blue/Green deployment
- **Application**: Use a simple web application (Docker containerized) as an example

## Deployment and Testing

### Requirements

- **Terraform**: Install by referring to the [Terraform official site](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI**: Install by referring to the [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and configure credentials for the AWS account to use
- **GitHub Account**: Account needed to push code and run GitHub Actions


### 1. Infrastructure Deployment (Terraform)

Create all AWS infrastructure (VPC, IAM, S3, ALB, ASG, CodeDeploy, etc.) required for Blue/Green deployment using Terraform.

1.  **Terraform Variable Configuration**

    ```bash
    git clone https://github.com/squatboy/codedeploy-blue-green-deploy.git
    cd codedeploy-blue-green-deploy/infra
    ```
    
    Go to the `infra` directory and create a `terraform.tfvars` file, filling in the content according to your environment.
    
    Example `terraform.tfvars` file:
    ```hcl
    # terraform.tfvars
    github_repo    = "squatboy/codedeploy-blue-green-deploy"
    s3_bucket_name = "your-unique-codedeploy-artifact-bucket-name"
    ```
    - `github_repo`: Path to the GitHub repository where this project will be pushed (e.g., `squatboy/codedeploy-blue-green-deploy`).
    - `s3_bucket_name`: Name of the S3 bucket where CodeDeploy will store deployment artifacts. Must be globally unique.

2.  **Terraform Execution**

    Run the following commands in sequence in the `infra` directory

    ```bash
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```


### 2. GitHub Repository Configuration

1.  **GitHub Repository Creation and Code Push**
    - Create a GitHub repository with the same path as the `github_repo` entered in `terraform.tfvars`
    - Push the entire `codedeploy-blue-green-deploy` project to that repository

2.  **Secrets Configuration for GitHub Actions**

    Go to the `Settings > Secrets and variables > Actions` menu of the GitHub repository and add the following Secrets. The `ap-northeast-2` region is hardcoded in the workflow, so no need to add it as a Secret.

    - `AWS_ACCOUNT_ID`: 12-digit numeric ID of the AWS account (e.g., `123456789012`)
    - `S3_BUCKET_NAME`: Enter the same value as the S3 bucket name entered in `terraform.tfvars`


### 3. First Deployment Execution and Verification

When code is pushed to the `main` branch, the `.github/workflows/cicd.yml` workflow will run automatically.

1.  **GitHub Actions Workflow Verification**
    - Go to the `Actions` tab of the repository and check if the workflow completed successfully.
    - The workflow performs the following steps:
        1. Authenticate to AWS with OIDC
        2. Build Docker image and push to ECR
        3. Compress application files into zip and upload to S3
        4. Create and start CodeDeploy deployment

2.  **CodeDeploy Deployment Status Verification**
    - Go to the [AWS CodeDeploy console](https://console.aws.amazon.com/codedeploy/home) and check if the deployment completed successfully

3.  **Application Access**
    - Access the `alb_dns_name` address obtained from Terraform results in a web browser
    - Verify that the example application's message "Hello, World! This is version 1.0" is displayed


### 4. Blue/Green Deployment Testing

Now, modify the application code to deploy a new version and verify that traffic is automatically switched.

1.  **Application Code Modification**
    - Modify the version information in the `app/index.js` file
    - Example
      ```javascript
      // app/index.js
      // ...
      const version = '2.0'; // 1.0 -> 2.0
      // ...
      ```

2.  **Push Code Changes**
    - Commit and push the changed code to the `main` branch
      ```bash
      git add app/index.js
      git commit -m "Update to version 2.0"
      git push origin main
      ```

3.  **Blue/Green Deployment Process Monitoring**
    - When code is pushed, a new GitHub Actions workflow runs and CodeDeploy deployment starts
    - Check deployment status in the AWS CodeDeploy console
    - **Step 1: Provisioning new instances (Green environment)**: CodeDeploy creates a new Auto Scaling Group ("Green" environment) and deploys the new version of the application
    - **Step 2: Rerouting traffic**: When instances in the Green environment are healthy, the ALB listener switches traffic from the Blue environment to the Green environment
    - **Step 3: Terminating old instances**: After the configured wait time passes after traffic switching, the old version instances ("Blue" environment) are terminated

      <img width="1472" height="584" alt="라우팅_전환2" src="https://github.com/user-attachments/assets/ec94a81a-df5d-4874-b46b-027139d4465c" />


4.  **Deployment Result Verification**
    - While "Step 2" of the deployment is in progress, refresh the `alb_dns_name` address in the web browser and confirm that it changes to the "Hello, World! This is version 2.0" message
      > This means traffic has been switched to the new version without downtime.
      <img width="1369" height="584" alt="codedeploy-2단계" src="https://github.com/user-attachments/assets/08469129-d526-460b-9031-d08b617bccdc" />


### 5. Resource Cleanup

After testing is completed, delete all created AWS resources to avoid unnecessary costs.

1.  **Terraform Resource Deletion**
    - Run the following command in the `infra` directory

      ```bash
      terraform destroy -auto-approve
      ```

2.  **S3 Bucket Verification**
    - `terraform destroy` generally cannot delete ECR and non-empty S3 buckets, so you can go to the console and delete them manually.

3.  **GitHub Repository Cleanup**
    - Delete the created GitHub repository and Secrets.
