# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the subnets associated with the default VPC
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Define Security Group for the ECS Task
resource "aws_security_group" "task_sg" {
  name        = "Task-SG"
  description = "Allow HTTP traffic from ALB"
  vpc_id      = data.aws_vpc.default.id

  # Ingress rule to allow HTTP traffic from the ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.HTTP-SG.id]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Fetch the ECS task definition
data "aws_ecs_task_definition" "simple_cluster_task" {
  task_definition = "simple-cluster-task"
}

# Define the ECS Service
resource "aws_ecs_service" "simple_cluster_service" {
  name            = "simple-cluster-service"
  cluster         = aws_ecs_cluster.ECS_Cluster.name
  task_definition = data.aws_ecs_task_definition.simple_cluster_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  # Network configuration for the ECS service
  network_configuration {
    subnets         = data.aws_subnets.default_subnets.ids
    security_groups = [aws_security_group.task_sg.id]
  }

  # Service discovery configuration
  service_registries {
    registry_arn = aws_service_discovery_service.backend_service.arn
  }

  # Load balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.TG.arn
    container_name   = "frontend"
    container_port   = 80
  }
}
