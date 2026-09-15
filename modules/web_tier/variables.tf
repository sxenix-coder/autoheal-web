variable "name_prefix" {
  description = "Prefix applied to all resource names in this module."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs the ALB and ASG are spread across (one per AZ)."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer."
  type        = string
}

variable "instance_security_group_id" {
  description = "Security group ID for the web tier instances."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used by the launch template."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "min_size" {
  description = "Minimum ASG size."
  type        = number
}

variable "max_size" {
  description = "Maximum ASG size."
  type        = number
}

variable "desired_capacity" {
  description = "Desired ASG capacity."
  type        = number
}

variable "health_check_grace_period" {
  description = "Seconds before health checks are enforced on a new instance."
  type        = number
}

variable "enable_container_mode" {
  description = "Run the page from a container image instead of native NGINX."
  type        = bool
}

variable "container_image" {
  description = "Container image to run when container mode is enabled."
  type        = string
}

variable "environment" {
  description = "Environment name, surfaced on the served page."
  type        = string
}
