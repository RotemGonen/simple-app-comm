
# Define ECS Cluster
# This resource creates an ECS cluster named "Test-Cluster" which will be used to run ECS tasks and services.
resource "aws_ecs_cluster" "ECS_Cluster" {
  name = "Test-Cluster"
}

# Fetch the latest Amazon ECS-optimized AMI
# This data source retrieves the most recent Amazon ECS-optimized AMI provided by Amazon.
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# Define Launch Template for EC2 instances
# This resource creates a launch template for EC2 instances that will be part of the ECS cluster.
# It specifies the AMI, instance type, SSH key, user data for ECS configuration, and IAM instance profile.
resource "aws_launch_template" "ecs_launch_template" {
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "t3.micro"
  key_name      = "MySSHCred" # My SSH Key

  # Add user_data to configure ECS_CLUSTER in order to register the instance with the ECS cluster
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=Test-Cluster" >> /etc/ecs/ecs.config
  EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
}

# Define Auto Scaling Group (ASG)
# This resource creates an Auto Scaling Group to manage the EC2 instances that will be part of the ECS cluster.
# It uses the launch template defined above and specifies the desired, minimum, and maximum capacity.
resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity = 1
  min_size         = 0
  max_size         = 1
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.default_subnets.ids # List of subnets for ASG
}

# Define EC2 Capacity Provider for ECS
# This resource creates an ECS capacity provider that uses the Auto Scaling Group to manage the EC2 instances.
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "capacity_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
  }
}

# Attach Capacity Provider to ECS Cluster
# This resource attaches the capacity provider to the ECS cluster, enabling the cluster to use the EC2 instances managed by the capacity provider.
resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ECS_Cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}

# Define IAM Role for ECS Instances
# This resource creates an IAM role that EC2 instances will assume to interact with ECS and other AWS services.
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"
  # this allows only EC2 instances to assume the role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach IAM Policy to ECS Instance Role
# This resource attaches the AmazonEC2ContainerServiceforEC2Role policy to the IAM role, granting necessary permissions for ECS instances.
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Define IAM Instance Profile for ECS Instances
# This resource creates an IAM instance profile that includes the IAM role, allowing EC2 instances to assume the role.
# The instance profile will be attached to the launch template for ECS instances.
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}

