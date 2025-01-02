# IAM Role for ECS Task Execution
resource "aws_iam_role" "app_task_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonECSTaskExecutionRolePolicy to allow ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.app_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for ECS task logging permissions to CloudWatch
resource "aws_iam_policy" "ecs_task_logging_policy" {
  name = "ECS_Task_Logging_Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the custom logging policy to the ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_logging_attachment" {
  role       = aws_iam_role.app_task_role.name
  policy_arn = aws_iam_policy.ecs_task_logging_policy.arn
}

# IAM Role for CodeDeploy
# IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy" {
  name               = "codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for full S3 access
resource "aws_iam_policy" "s3_full_access" {
  name        = "s3-full-access-policy"
  description = "Policy to provide full access to S3 for the CodeDeploy role"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "codedeploy_s3_attachment" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}


# Custom inline policy for CodeDeploy to access necessary services
resource "aws_iam_policy" "custom_codedeploy_policy" {
  name = "CustomCodeDeployPolicyForECS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:*",
          "ecs:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "iam:PassRole",
          "s3:Get*",
          "s3:List*"
        ],
        Resource: "*"
      }
    ]
  })
}

# Attach the custom policy to the CodeDeploy role
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.custom_codedeploy_policy.arn
}
