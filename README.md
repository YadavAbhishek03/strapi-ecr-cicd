
# 🚀 DevOps Terraform Project – Strapi on AWS EC2

This project automates the deployment of a [Strapi](https://strapi.io/) application on an AWS EC2 instance using Terraform.

---

## 📁 Project Structure

terraform/
    ├── main.tf # Main Terraform configuration 
    ├── outputs.tf # Terraform output values 
    ├── variables.tf # Terraform input variables 
    ├── user_data.sh # Script to install and run Strapi on EC2 
    ├── terraform.tfstate # Terraform state file (ignored) 
    ├── terraform.tfstate.backup 
    ├── ssh-key/ # Directory containing your SSH



---

## 🔧 Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- AWS CLI configured with your credentials
       aws configure
- An AWS Key Pair for SSH access
       ssh-keygen

---

## 🌱 Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/your-username/your_repo-name.git
   cd your_repo-name/terraform


## Initialize Terraform:
   terraform init

##  Create a terraform.tfvars file:
      aws_region    = "us-east-1"
      instance_type = "t2.micro"
      key_name      = "your-key-name"
      public_key    = "ssh-rsa AAAAB3...your key"

## Apply the configuration:
    terraform apply

## Access Strapi at:
    http://<your-ec2-public-ip>:1337/admin

🔐 Security
Ensure sensitive files like your keys and state files are not pushed to version control. See .gitignore below.


## 🧹 Cleanup: To destroy the infrastructure:
      terraform destroy



---

### ✅ `.gitignore`

```gitignore
# Ignore Terraform state
*.tfstate
*.tfstate.*
.terraform/

# Ignore secrets
terraform.tfvars
*.pem
*.key
*.crt

# SSH key folder
ssh-key/

# System files
.DS_Store

# Logs
*.log

# Editor files
*.swp
.idea/
.vscode/

>>>>>>> 33e7b74 (Created file to deploy strapi using terraform)
