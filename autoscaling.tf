# Launch template for front-end ECS instances
resource "aws_launch_template" "ecs_launch_template" {
  name          = "ecs-launch-template"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "t3.small"  # Adjust as needed
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_instance_sg.id]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.app_cluster.name}" > /etc/ecs/ecs.config
            EOF
  )
}

# Launch template for back-end ECS instances
resource "aws_launch_template" "ecs_launch_template_backend" {
  name          = "ecs-launch-template-backend"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "t3.small"  # Adjust as needed
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_instance_sg.id]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.backend_cluster.name}" > /etc/ecs/ecs.config
            EOF
  )
}


# Autoscaling group for front-end ECS instances
resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = module.vpc.public_subnets
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  health_check_type          = "EC2"
  health_check_grace_period  = 300

  tag {
    key                 = "Name"
    value               = "ECSInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Autoscaling group for back-end ECS instances
resource "aws_autoscaling_group" "ecs_asg_backend" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = module.vpc.public_subnets
  launch_template {
    id      = aws_launch_template.ecs_launch_template_backend.id
    version = "$Latest"
  }
  health_check_type          = "EC2"
  health_check_grace_period  = 300

  tag {
    key                 = "Name"
    value               = "ECSInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for ECS instances in the ASG
resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs-instance-sg"
  description = "Security group for ECS instances in ASG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all IPs to access all ports
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM instance profile and role for ECS
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# IAM role for ECS instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Fetch latest ECS optimized AMI
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}