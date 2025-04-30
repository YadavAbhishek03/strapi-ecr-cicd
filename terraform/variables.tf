variable "aws_region" {
  default = "us-east-1"
}

variable "ecr_image_url" {
  description = "ECR image URL for Strapi container"
  type        = string
  default     = "118273046134.dkr.ecr.us-east-1.amazonaws.com/abhi-strapi-app:latest"
}


variable "ecs_execution_role_arn" {
  description = "ARN of an existing ECS task execution role"
  type        = string
  default     = "arn:aws:iam::118273046134:role/abhi_ecsTaskExecutionRole"
}

variable "codedeploy_service_role_arn" {
  description = "ARN of an existing service role"
  type        = string
  default     = "arn:aws:iam::118273046134:role/abhi-codedeploy-ecs-role"
}

variable "api_token_salt" {
  description = "API Token Salt"
  type        = string
}

variable "admin_jwt_secret" {
  description = "Admin JWT Secret"
  type        = string
}

variable "transfer_token_salt" {
  description = "Transfer Token Salt"
  type        = string
}

variable "app_keys" {
  description = "App Keys"
  type        = string
}