#This is the front-end load balancer
resource "aws_lb" "app_lb" {
  name               = "application-load-balancer"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  idle_timeout       = 60
  security_groups    = [module.lb_security_group.security_group_id]
}

#This is the backend loadbalancer
resource "aws_lb" "backend_lb" {
  name               = "backend-load-balancer"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  idle_timeout       = 60
  security_groups    = [module.lb_security_group.security_group_id]
}

# These are the frontend listeners
# Rename the existing HTTP listener on port 80 to `l_80_redirect`

#Frontend 80
resource "aws_alb_listener" "l_80_redirect" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

#Frontend 443
resource "aws_alb_listener" "l_80" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-north-1:038462779186:certificate/c65ef6dd-213b-4f19-ac6f-f7683c9b66d0" # Replace with your ACM certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
}

# Frontend 8080
resource "aws_alb_listener" "l_8080" {
  load_balancer_arn = aws_lb.app_lb.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[1].arn
  }
}

# These are the backend listeners
# backend 443
resource "aws_alb_listener" "backend_80" {
  load_balancer_arn = aws_lb.backend_lb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-north-1:038462779186:certificate/cbe8346b-d43f-4af5-9ddd-b890c0043d65"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[0].arn
  }
  }

  # backend 8080

resource "aws_alb_listener" "backend_8080" {
  load_balancer_arn = aws_lb.backend_lb.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[1].arn
  }
}
# backend 80
resource "aws_alb_listener" "l_80_backend_redirect" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}