# Strapi Deployment on AWS with ECS Fargate

This project demonstrates how to deploy a Strapi application on AWS using ECS Fargate, with infrastructure managed using Terraform. The deployment includes provisioning an Application Load Balancer (ALB), VPC, subnets, ECS cluster, ECS service, and more.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Docker](https://www.docker.com/get-started)
- [AWS Account](https://aws.amazon.com/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Yarn](https://yarnpkg.com/) (for Strapi app dependencies)


## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/YadavAbhishek03/devops-terraform-project.git
cd devops-terraform-project

## Build and Push Docker Image
## Before deploying, you need to build the Docker image for the Strapi app and push it to Amazon Elastic Container Registry (ECR).

# Build Docker image
docker build -t strapi-app .

# Login to AWS ECR
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com

# Tag the image for ECR
docker tag strapi-app:latest <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/strapi-repository:latest

# Push the image to ECR
docker push <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/strapi-repository:latest

## Configure Terraform
## Ensure you have AWS credentials configured and that you have set the appropriate region and other variables.

## Create or update the .env file with your AWS credentials, region, and ECR image URL.

AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=your-region
ECR_IMAGE_URL=<aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/strapi-repository:latest

## Apply Terraform Configuration
## Run the following Terraform commands to provision AWS resources:

# Initialize Terraform
terraform init

# Plan the changes
terraform plan

# Apply the changes
terraform apply

## Terraform will create all necessary resources such as ECS clusters, security groups, ALB, subnets, and ECS services. Make sure to confirm the apply action when prompted.

## Access the Application
## Once the deployment is complete, you can access the Strapi application via the Load Balancer URL. To get the Load Balancer's DNS name:

# Get the DNS name of the load balancer
terraform output load_balancer_dns_name


## Useful Terraform Commands
terraform init : Initializes the Terraform configuration.

terraform plan : Plans the infrastructure changes.

terraform apply : Applies the changes and creates the infrastructure.

terraform destroy : Destroys the resources managed by Terraform.