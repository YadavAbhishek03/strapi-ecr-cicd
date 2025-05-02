# 🚀 Strapi Blue/Green Deployment on AWS ECS using GitHub Actions & Terraform

This project automates the deployment of a Dockerized Strapi CMS application using:

- **Terraform** for AWS infrastructure provisioning
- **ECS Fargate** for running containers
- **AWS CodeDeploy (Blue/Green strategy)** for zero-downtime deployments
- **GitHub Actions** for CI/CD

---

## 📁 Project Structure

strapi-deployment/
├── strapi/ # Dockerized Strapi app
│
├──Dockerfile 
│
├── terraform/ # Terraform infra
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── terraform.tfvars
│
└── .github/
 └── workflows/
  └── cicd.yml # CI/CD workflow (now disabled)



---

## 🌐 Features

- Full AWS infrastructure with ECS Fargate, ALB, Target Groups, and CodeDeploy
- Blue/Green deployment with **canary strategy** (10% shift, 5-minute test)
- GitHub Actions CI/CD pipeline
- Strapi served on port `1337`
- Secure and isolated setup using custom VPC and Security Groups

---

## 🔐 GitHub Secrets Required

Ensure the following secrets are set in your GitHub repository:

| Secret Name                    | Description                                  |
|-------------------------------|----------------------------------------------|
| `AWS_ACCESS_KEY_ID`           | Your AWS access key                          |
| `AWS_SECRET_ACCESS_KEY`       | Your AWS secret key                          |
| `AWS_REGION`                  | AWS region (e.g. `us-east-1`)                |
| `ECR_REPOSITORY`              | Name of your ECR repository                  |
| `ECR_REGISTRY`                | Your AWS account ID and region (e.g. `123456789012.dkr.ecr.us-east-1.amazonaws.com`) |
| `CODEDEPLOY_APP_NAME`         | CodeDeploy app name (e.g. `strapi-codedeploy-app`) |
| `CODEDEPLOY_DEPLOY_GROUP`     | CodeDeploy deploy group (e.g. `strapi-deploy-group`) |
| `CLUSTER_NAME`                | ECS Cluster name (e.g. `strapi-cluster`) |
| `SERVICE_NAME`                | ECS Service name (e.g. `strapi-service`) |

---

## 🚀 How It Works

1. GitHub Actions builds and pushes a Docker image to Amazon ECR.
2. Terraform provisions the infrastructure on AWS.
3. AppSpec and CodeDeploy config is generated and used for a **blue/green** deployment.
4. Canary strategy is used: 10% traffic for 5 minutes, then 100% if healthy.

---

## ✅ Disable GitHub Actions (Done ✅)

You’ve commented out the workflow trigger in `.github/workflows/cicd.yml` to stop the pipeline after project completion.

---

## 📊 Monitoring Deployment

- View deployment status in **AWS CodeDeploy → Deployments**
- Check metrics and logs in:
  - ECS Task Logs (via CloudWatch)
  - CodeDeploy events
  - ALB Target Group health checks

---

## ⚙️ CI/CD Workflow (GitHub Actions)
- Triggered On:
- Push to main branch

- Workflow Steps:
- Build Docker image
- Push to ECR
- Register ECS Task Definition
- Create appspec.json
- Trigger CodeDeploy Blue/Green deployment


## ✅ Monitoring Deployment
CodeDeploy Console:
AWS CodeDeploy

ECS Service:
AWS ECS

Target Group Health:
EC2 Target Groups

## 🧪 Health Checks
Ensure your Strapi container:

Exposes port 1337
Defines container health checks (optional but recommended)


## 📝 Example Output
Once deployed successfully, your app is available via the ALB DNS name:

    http://<alb-dns-name>:1337/admin
    

## 🧹 Cleanup
To destroy all AWS resources:

    cd terraform
    terraform destroy


## 🙌 Credits
Built with:
Strapi
Terraform
AWS ECS & CodeDeploy
GitHub Actions

## 📬 Author

**Abhishek** – DevOps Project with GitHub Actions + Terraform + AWS ECS Blue/Green Deployment  


