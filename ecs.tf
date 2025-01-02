resource "aws_ecs_cluster" "app_cluster" {
  name = "application_cluster"
}

resource "aws_ecs_cluster" "backend_cluster" {
  name = "backend_cluster"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = var.ecs_log_group_name
  retention_in_days = 7
}


resource "aws_ecs_service" "frontend" {
  name                               = "frontend"
  cluster                            = aws_ecs_cluster.app_cluster.id
  task_definition                    = aws_ecs_task_definition.frontend_task.arn
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"
  desired_count                      = var.blue_instance_count

  load_balancer {
    target_group_arn = aws_lb_target_group.tg[0].arn  # First target group for port 80
    container_name   = "app"
    container_port   = 3001
  }


  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [aws_lb.app_lb]

  lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }

  count = var.enable_blue_env ? 1 : 0
}

resource "aws_ecs_service" "backend" {
  name                               = "backend"
  cluster                            = aws_ecs_cluster.backend_cluster.id
  task_definition                    = aws_ecs_task_definition.backend_task.arn
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"
  desired_count                      = var.blue_instance_count

  load_balancer {
    target_group_arn = aws_lb_target_group.backend[0].arn  # First target group for port 80
    container_name   = "app"
    container_port   = 5001
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [aws_lb.backend_lb]

  lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }

}


# Task definiton for the front-end app.
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  requires_compatibilities = ["EC2"]
  memory                   = var.ecs_task_memory
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.app_task_role.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.frontend_app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.ecs_container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.ecs_log_group_name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])

  depends_on = [aws_ecr_repository.frontend_app]
}

# Task definition for the backend app.13.61.16.14
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  requires_compatibilities = ["EC2"]
  memory                   = var.ecs_task_memory
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.app_task_role.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.backend_app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 5001
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.ecs_log_group_name
        awslogs-stream-prefix = "back-ecs"
        awslogs-region        = var.region
      }
    }
  }])

  depends_on = [aws_ecr_repository.backend_app]
}

# Creating a task definiton file for the front-end app
data "template_file" "appspec_content" {
  template = <<-EOT
    version: 0.0
    Resources:
      - TargetService:
          Type: AWS::ECS::Service
          Properties:
            TaskDefinition: ${aws_ecs_task_definition.frontend_task.arn}
            LoadBalancerInfo:
              ContainerName: app
              ContainerPort: 3001
  EOT
}

# Create the local appspec.yaml file
resource "local_file" "appspec_yaml" {
  content  = data.template_file.appspec_content.rendered
  filename = "${path.module}/appspec.yaml"
}

# Upload appspec.yaml to S3
resource "aws_s3_object" "appspec_yaml_s3" {
  bucket = "deployment-bckt-frontend"  # Replace with your S3 bucket name
  key    = "appspec.yaml"
  source = local_file.appspec_yaml.filename
  acl    = "private"
}

# Output the task definition ARN
output "frontend_task_definition_arn" {
  value = aws_ecs_task_definition.frontend_task.arn
}


#Creating a task defintion file for the backend app
data "template_file" "appspec_backend" {
  template = <<-EOT
    version: 0.0
    Resources:
      - TargetService:
          Type: AWS::ECS::Service
          Properties:
            TaskDefinition: ${aws_ecs_task_definition.backend_task.arn}
            LoadBalancerInfo:
              ContainerName: app
              ContainerPort: 5001
  EOT
}

# Create the local appspec.yaml file
resource "local_file" "backend_appspec_yaml" {
  content  = data.template_file.appspec_backend.rendered
  filename = "${path.module}/backend_appspec.yaml"
}

# Upload appspec.yaml to S3
resource "aws_s3_object" "backend_appspec_yaml_s3" {
  bucket = "deployment-bckt-backend"  # Replace with your S3 bucket name
  key    = "backend_appspec.yaml"
  source = local_file.backend_appspec_yaml.filename
  acl    = "private"
}

# Output the task definition ARN
output "backend_task_definition_arn" {
  value = aws_ecs_task_definition.backend_task.arn
}