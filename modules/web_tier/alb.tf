###############################################################################
# Application Load Balancer
###############################################################################

resource "aws_lb" "this" {
  name_prefix        = "ahweb-" # ALB name_prefix is limited to 6 characters
  load_balancer_type = "application"
  internal           = false
  subnets            = var.subnet_ids
  security_groups    = [var.alb_security_group_id]

  # Safe to enable in dev; set to true for prod to guard against accidental
  # `terraform destroy`.
  enable_deletion_protection = false

  drop_invalid_header_fields = true

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "this" {
  name_prefix = "ahweb-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Deregistration delay kept short so replaced instances leave the pool
  # quickly during a self-healing event.
  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    Name = "${var.name_prefix}-listener-http"
  }
}
