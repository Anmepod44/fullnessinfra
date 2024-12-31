#ecr repo for the front-end app.
resource "aws_ecr_repository" "frontend_app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

}
#ecr repo for the backend app.
resource "aws_ecr_repository" "backend_app" {
  name                 = var.ecr_back_repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

}

# Output the ECR repository URI
output "ecr_repository_url" {
  description = "The URL of the Front-end ECR repository"
  value       = aws_ecr_repository.frontend_app.repository_url
}

# Output the ECR repository URI
output "ecr_backend_repository_url" {
  description = "The URL of the Back-end ECR repository"
  value       = aws_ecr_repository.backend_app.repository_url
}