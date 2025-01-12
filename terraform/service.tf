
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Define Security Group for The Task
resource "aws_security_group" "task_sg" {
  name        = "Task-SG"
  description = "Allow HTTP traffic from ALB and inernal traffic to the backend"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.HTTP-SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ecs_task_definition" "simple_cluster_task" {
  task_definition = "simple-cluster-task"
}

resource "aws_ecs_service" "simple_cluster_service" {
  name            = "simple-cluster-service"
  cluster         = aws_ecs_cluster.ECS_Cluster.name
  task_definition = data.aws_ecs_task_definition.simple_cluster_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets         = data.aws_subnets.default_subnets.ids
    security_groups = [aws_security_group.task_sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.backend_service.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.TG.arn
    container_name   = "frontend"
    container_port   = 80
  }
}
