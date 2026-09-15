output "alb_security_group_id" {
  description = "Security group ID attached to the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "instance_security_group_id" {
  description = "Security group ID attached to the web tier instances."
  value       = aws_security_group.instance.id
}
