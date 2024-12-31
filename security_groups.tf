# Security groups are created in main.tf using modules for modularization.

output "app_security_group_id" {
  value = module.app_security_group.security_group_id
}

output "lb_security_group_id" {
  value = module.lb_security_group.security_group_id
}