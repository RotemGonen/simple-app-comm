# Create an Application Load Balancer
resource "aws_lb" "alb" {
  name                             = "Simple-ALB"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.HTTP-SG.id]
  subnets                          = data.aws_subnets.default_subnets.ids
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}

# Create a listener for the ALB on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

# Create a security group for the ALB
resource "aws_security_group" "HTTP-SG" {
  name        = "HTTP-SG"
  description = "Allow HTTP traffic from the web"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from all IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a target group for the ECS service
resource "aws_lb_target_group" "TG" {
  name        = "tg-ecs-service"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
# # Fetch the public IP of the current machine
# data "http" "my_ip" {
#   url = "https://checkip.amazonaws.com/"
# }
# output "my_ip" {
#   value = "${trimspace(data.http.my_ip.response_body)}/32" # Output the fetched IP with /32
# }
