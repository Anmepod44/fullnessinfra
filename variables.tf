# General AWS settings
variable "region" {
  description = "The AWS region where Terraform will deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "aws_account_id" {
  description = "The AWS account ID used for ECR and IAM configurations"
  type        = string
  default     = "038462779186"  # Replace with your actual AWS account ID
}

variable "aws_account_region" {
  description = "The AWS account region for ECR"
  type        = string
  default     = "eu-north-1"
}

# VPC settings
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC"
  type        = bool
  default     = false
}

# Subnet settings
variable "public_subnet_count" {
  description = "Number of public subnets in the VPC"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets in the VPC"
  type        = number
  default     = 2
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24"
  ]
}

# Load Balancer settings
variable "elb_sg_ingress_ports" {
  description = "List of ingress ports for the ELB security group"
  type        = list(number)
  default     = [80, 443, 8080]
}

variable "lb_target_group_name" {
  description = "Base name for the load balancer target groups"
  type        = string
  default     = "tg"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener on port 443"
  type        = string
  default     = ""  # Add the certificate ARN if HTTPS is required
}

# Blue/Green Deployment settings
variable "enable_blue_env" {
  description = "Enable blue environment for Blue/Green deployment"
  type        = bool
  default     = true
}

variable "enable_green_env" {
  description = "Enable green environment for Blue/Green deployment"
  type        = bool
  default     = true
}

variable "blue_instance_count" {
  description = "Number of instances in the blue environment"
  type        = number
  default     = 1
}

variable "green_instance_count" {
  description = "Number of instances in the green environment"
  type        = number
  default     = 1
}

# ECS Task Definition and Service settings
variable "ecs_task_memory" {
  description = "Memory allocated for the ECS task"
  type        = number
  default     = 128
}

variable "ecs_task_cpu" {
  description = "CPU allocated for the ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_execution_role_name" {
  description = "Name of the IAM role used for ECS task execution"
  type        = string
  default     = "app-task-role"
}

variable "ecs_container_port" {
  description = "Port used by the container within the ECS task"
  type        = number
  default     = 3001
}

variable "ecs_log_group_name" {
  description = "Name of the CloudWatch log group for ECS task logging"
  type        = string
  default     = "/ecs/app"
}

# ASG settings
variable "asg_desired_capacity" {
  description = "Desired capacity for ECS ASG"
  type        = number
  default     = 1
}

variable "asg_min_size" {
  description = "Minimum capacity for ECS ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum capacity for ECS ASG"
  type        = number
  default     = 2
}


variable "ecr_repo_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "frontend-app"  # Default value; can be overridden if needed
}

variable "ecr_back_repo_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "backend-app"  # Default value; can be overridden if needed
}


variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "backenddb"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "backend"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
  default     = "password123"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "db_allocated_storage" {
  description = "The allocated storage in GBs"
  type        = number
  default     = 20
}

variable "db_subnet_group_name" {
  description = "The subnet group name for the RDS instance"
  type        = string
  default     = null
}

# WAF Configuration
variable "waf_acl_name" {
  description = "Name of the WAF ACL"
  type        = string
  default     = "webacl"
}

variable "accelerator_name" {
  description = "Name for the Global Accelerator"
  type        = string
  default     = "my-global-accelerator"
}

variable "listener_port" {
  description = "Port for the Global Accelerator listener"
  type        = number
  default     = 80  # Set to 80 for HTTP, or change to 443 if HTTPS is needed
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access the database"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with specific IP ranges for security
}