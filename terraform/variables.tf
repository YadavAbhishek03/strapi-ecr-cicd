variable "aws_region" {
  default = "us-east-1"
}

variable "ecr_image_url" {
  description = "ECR image URL"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of an existing ECS task execution role"
  type        = string
}
