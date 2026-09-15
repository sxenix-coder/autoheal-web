###############################################################################
# Locals - naming convention and common tags
#
# Naming convention: <project>-<environment>-<resource>
#   e.g. autoheal-web-dev-vpc, autoheal-web-dev-alb
###############################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCentre  = var.cost_centre
    ManagedBy   = "terraform"
  }
}

###############################################################################
# Data sources
###############################################################################

# Only the AZs that actually support the chosen instance type are usable.
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Latest Amazon Linux 2023 AMI for the correct CPU architecture.
# t4g.* instances are ARM64; t3.*/t2.* are x86_64.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [local.is_arm ? "al2023-ami-2023.*-arm64" : "al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  # t4g / m6g / c7g etc. are Graviton (ARM64).
  is_arm = can(regex("^(t4g|m6g|m7g|c6g|c7g|r6g|r7g)\\.", var.instance_type))

  resolved_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id

  # Take only as many AZs as requested, in a deterministic order.
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count)
}

###############################################################################
# Modules
###############################################################################

module "networking" {
  source = "./modules/networking"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = local.azs
}

module "security" {
  source = "./modules/security"

  name_prefix       = local.name_prefix
  vpc_id            = module.networking.vpc_id
  allowed_http_cidr = var.allowed_http_cidr
}

module "web_tier" {
  source = "./modules/web_tier"

  name_prefix = local.name_prefix

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.public_subnet_ids

  alb_security_group_id      = module.security.alb_security_group_id
  instance_security_group_id = module.security.instance_security_group_id

  ami_id        = local.resolved_ami_id
  instance_type = var.instance_type

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = var.health_check_grace_period

  enable_container_mode = var.enable_container_mode
  container_image       = var.container_image

  environment = var.environment
}
