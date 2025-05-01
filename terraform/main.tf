provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "abhi-strapi-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
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

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "abhi-alb-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 1337
  to_port     = 1337
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

resource "aws_security_group" "ecs_sg" {
  name        = "abhi-ecs-sg"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer & Target Group
resource "aws_lb" "alb" {
  name               = "abhi-strapi-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "blue" {
  name        = "abhi-strapi-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "abhi-strapi-green-tg"
  port        = 1337
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# ALB Listeners
# Primary Listener (Port 80) - Will be managed by CodeDeploy
resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# Secondary Listener (Port 1337) - Static mapping to current production
resource "aws_lb_listener" "http_1337" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 1337
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# CodeDeploy Application
resource "aws_codedeploy_app" "strapi_codedeploy_app" {
  name = "abhi-strapi-codedeploy-app"
  compute_platform = "ECS"
}


# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "strapi_codedeploy_group" {
  app_name              = aws_codedeploy_app.strapi_codedeploy_app.name
  deployment_group_name = "abhi-strapi-deploy-group"
  service_role_arn      = var.codedeploy_service_role_arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.strapi.name
    service_name = aws_ecs_service.strapi.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http_80.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi" {
  name = "abhi-strapi-cluster"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/abhi-strapi"
  retention_in_days = 7
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "abhi-strapi"
    image     = var.ecr_image_url
    cpu       = 1024
    memory    = 2048
    essential = true
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]
    environment = [
      { name = "API_TOKEN_SALT", value = var.api_token_salt },
      { name = "ADMIN_JWT_SECRET", value = var.admin_jwt_secret },
      { name = "TRANSFER_TOKEN_SALT", value = var.transfer_token_salt },
      { name = "APP_KEYS", value = var.app_keys }
    ]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.strapi.name,
        awslogs-region        = var.aws_region,
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

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
  # launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Add capacity provider strategy for Fargate Spot
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }


  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.alb_sg.id, aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "abhi-strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.http_80]
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "High-CPU-Utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name          = "High-Memory-Utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when memory exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_network_in" {
  alarm_name          = "strapi-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkBytesIn"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 100000000 # 100MB
  alarm_description   = "High incoming traffic"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_network_out" {
  alarm_name          = "strapi-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkBytesOut"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 100000000 # 100MB
  alarm_description   = "High outgoing traffic"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_task_count" {
  alarm_name          = "strapi-task-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "No running ECS tasks"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }
}