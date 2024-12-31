# CodeDeploy Application
resource "aws_codedeploy_app" "frontend" {
  compute_platform = "ECS"
  name             = "frontend-deploy"
}

# CodeDeploy Application
resource "aws_codedeploy_app" "backend" {
  compute_platform = "ECS"
  name             = "backend-deploy"
}

# Custom Deployment Configuration for 10% Traffic Shift Every 1 Hour
resource "aws_codedeploy_deployment_config" "custom_25_percent_permin" {
  deployment_config_name = "Custom25PercentEvery1Minutes"
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "TimeBasedLinear"

    time_based_linear {
      interval   = 1   # Shift traffic every 60 minutes (1 hour)
      percentage = 25   # Shift 10% of traffic each hour
    }
  }
}

# IAM Role for CodeDeploy (assuming already defined elsewhere)
# Ensure aws_iam_role.codedeploy exists and has necessary policies.

# CodeDeploy Deployment Group using the Custom Deployment Configuration
resource "aws_codedeploy_deployment_group" "frontend" {
  app_name               = aws_codedeploy_app.frontend.name
  deployment_group_name  = "frontend-deploy-group"
  deployment_config_name = aws_codedeploy_deployment_config.custom_25_percent_permin.id
  service_role_arn       = aws_iam_role.codedeploy.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.app_cluster.name
    service_name = aws_ecs_service.frontend[0].name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.tg[0].name
      }
      target_group {
        name = aws_lb_target_group.tg[1].name
      }

      prod_traffic_route {
        listener_arns = [aws_alb_listener.l_80.arn]  # Primary listener.
      }
      test_traffic_route {
        listener_arns = [ aws_alb_listener.l_8080.arn] #secondary listener.
      }
    }
  }
}


# Backend code deployment group.
resource "aws_codedeploy_deployment_group" "backend" {
  app_name               = aws_codedeploy_app.backend.name
  deployment_group_name  = "backend-deploy-group"
  deployment_config_name = aws_codedeploy_deployment_config.custom_25_percent_permin.id
  service_role_arn       = aws_iam_role.codedeploy.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.backend_cluster.name
    service_name = aws_ecs_service.backend.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.backend[0].name
      }
      target_group {
        name = aws_lb_target_group.backend[1].name
      }

      prod_traffic_route {
        listener_arns = [aws_alb_listener.backend_80.arn]  # Primary listener.
      }
      test_traffic_route {
        listener_arns = [ aws_alb_listener.backend_8080.arn] #secondary listener.
      }
    }
  }
}