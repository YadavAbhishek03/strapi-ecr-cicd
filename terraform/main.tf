provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "abhi-strapi-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "abhi-strapi-public-subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Availability Zones
data "aws_availability_zones" "available" {}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "abhi-strapi-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
}

# ALB Target Group
resource "aws_lb_target_group" "tg" {
  name     = "abhi-strapi-tg"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/admin"  # Ensure the health check path is correct
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# ALB Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi" {
  name = "abhi-strapi-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn
  container_definitions = jsonencode([{
    name  = "abhi-strapi"
    image = var.ecr_image_url
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
    }]
  }])

  # Adding force new revision
  lifecycle {
    create_before_destroy = true
  }
}

# ECS Service
resource "aws_ecs_service" "strapi" {
  name            = "abhi-strapi-service"
  cluster         = aws_ecs_cluster.strapi.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  health_check_grace_period_seconds = 60
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.alb_sg.id, aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "abhi-strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.listener]
}
