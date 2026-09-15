###############################################################################
# Core identity / tagging
###############################################################################

variable "project_name" {
  description = "Short project identifier used as the prefix for all resource names."
  type        = string
  default     = "autoheal-web"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.project_name))
    error_message = "project_name must be 3-24 characters, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "Deployment environment. Forms part of the resource naming convention."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "owner" {
  description = "Team or individual accountable for these resources (Owner tag)."
  type        = string
  default     = "platform-engineering"
}

variable "cost_centre" {
  description = "Cost centre used for billing allocation (CostCentre tag)."
  type        = string
  default     = "engineering"
}

###############################################################################
# Region / networking
###############################################################################

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-southeast-2" # Sydney - lowest latency for AU users
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone_count" {
  description = "Number of Availability Zones to spread the web tier across. Minimum 2 to satisfy N+1."
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 3
    error_message = "availability_zone_count must be between 2 and 3 to maintain N+1 redundancy."
  }
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach the load balancer on HTTP. Restrict this in a real deployment."
  type        = string
  default     = "0.0.0.0/0"
}

###############################################################################
# Compute / scaling
###############################################################################

variable "instance_type" {
  description = "EC2 instance type for the web tier. t4g.* are ARM (Graviton) and cheapest for this workload."
  type        = string
  default     = "t4g.nano"
}

variable "ami_id" {
  description = <<-EOT
    Optional AMI ID override. Leave empty to resolve the latest Amazon Linux 2023
    AMI via a data source. Pin this to a specific AMI if you need byte-for-byte
    idempotency across long time gaps (see README - Idempotency notes).
  EOT
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum number of instances. Must be >= 2 so the tier survives losing any single VM."
  type        = number
  default     = 2

  validation {
    condition     = var.asg_min_size >= 2
    error_message = "asg_min_size must be at least 2 to satisfy the N+1 capacity requirement."
  }
}

variable "asg_max_size" {
  description = "Maximum number of instances the ASG may scale to."
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired steady-state instance count."
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Seconds to wait after instance launch before health checks count against it."
  type        = number
  default     = 120
}

###############################################################################
# Application delivery mode
###############################################################################

variable "enable_container_mode" {
  description = <<-EOT
    When true, instances install Docker and run the container image defined by
    container_image instead of installing NGINX natively. This is the optional
    bonus path described in the brief.
  EOT
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Container image to pull and run when enable_container_mode is true."
  type        = string
  default     = "ghcr.io/OWNER/autoheal-web:latest"
}
