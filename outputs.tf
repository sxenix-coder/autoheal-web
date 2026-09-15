output "web_url" {
  description = "Public URL of the load-balanced web tier."
  value       = "http://${module.web_tier.alb_dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.web_tier.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group responsible for self-healing."
  value       = module.web_tier.autoscaling_group_name
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets hosting the web tier."
  value       = module.networking.public_subnet_ids
}

output "availability_zones" {
  description = "Availability Zones the web tier is spread across."
  value       = local.azs
}

output "resolved_ami_id" {
  description = "AMI ID used by the launch template."
  value       = local.resolved_ami_id
}

output "self_healing_test_command" {
  description = "Command to terminate one instance and observe automatic replacement."
  value       = <<-EOT
    aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-names ${module.web_tier.autoscaling_group_name} \
      --region ${var.aws_region} \
      --query 'AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState,HealthStatus]' \
      --output table

    # Then terminate any one instance ID from the list above:
    # aws ec2 terminate-instances --instance-ids <id> --region ${var.aws_region}
    # The ASG will detect the unhealthy target and launch a replacement.
  EOT
}
