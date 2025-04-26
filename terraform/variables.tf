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
  default     = "arn:aws:iam::118273046134:role/ecsTaskExecutionRole"
}
