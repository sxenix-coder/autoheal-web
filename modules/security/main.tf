###############################################################################
# ALB security group
#
# Accepts HTTP from the internet (or a restricted CIDR) and is the only source
# permitted to reach the instances.
###############################################################################

resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  description = "Ingress to the Application Load Balancer"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from allowed CIDR"

  cidr_ipv4   = var.allowed_http_cidr
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name = "${var.name_prefix}-alb-ingress-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_to_instances" {
  security_group_id = aws_security_group.alb.id
  description       = "Forward traffic to web instances only"

  referenced_security_group_id = aws_security_group.instance.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"

  tags = {
    Name = "${var.name_prefix}-alb-egress-instances"
  }
}

###############################################################################
# Instance security group
#
# Ingress is restricted to the ALB security group - the instances are never
# directly reachable from the internet even though they sit in public subnets.
# No SSH ingress is defined; use SSM Session Manager if shell access is needed.
###############################################################################

resource "aws_security_group" "instance" {
  name_prefix = "${var.name_prefix}-instance-"
  description = "Web tier instances - ALB ingress only"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_from_alb" {
  security_group_id = aws_security_group.instance.id
  description       = "HTTP from the ALB security group only"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"

  tags = {
    Name = "${var.name_prefix}-instance-ingress-alb"
  }
}

# Outbound is required for package installation (dnf) and, in container mode,
# pulling the image from the registry.
resource "aws_vpc_security_group_egress_rule" "instance_all" {
  security_group_id = aws_security_group.instance.id
  description       = "Outbound for package and image retrieval"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "${var.name_prefix}-instance-egress-all"
  }
}
