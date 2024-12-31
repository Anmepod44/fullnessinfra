locals {
  target_groups_front = ["blue", "green"]
  target_groups_back = ["blue-backend", "green-backend"]
  target_ports  = [80, 8080]  # Define ports based on target group requirements
}


# Below are the front-end target groups.
resource "aws_lb_target_group" "tg" {
  count       = length(local.target_groups_front)
  name        = "${var.lb_target_group_name}-${local.target_groups_front[count.index]}"
  port        = 80
  #local.target_ports[count.index]
  protocol    = "HTTP"# local.target_ports[count.index]  # Dynamically assign ports
  target_type = "instance"  # Change to 'ip' if using Fargate launch type
  vpc_id      = module.vpc.vpc_id
}


# Backend target groups with custom health checks
resource "aws_lb_target_group" "backend" {
  count       = length(local.target_groups_back)
  name        = "${var.lb_target_group_name}-${local.target_groups_back[count.index]}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  # Custom health check configuration
  health_check {
    interval            = 30            # Time in seconds between health checks
    path                = "/docs"       # Path to check for health
    protocol            = "HTTP"        # Protocol for health check
    timeout             = 5             # Timeout in seconds for health check response
    healthy_threshold   = 3             # Number of consecutive successes to mark as healthy
    unhealthy_threshold = 2             # Number of consecutive failures to mark as unhealthy
  }
}
