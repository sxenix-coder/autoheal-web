###############################################################################
# Auto Scaling Group - this is what delivers self-healing
#
# health_check_type = "ELB" means the ASG trusts the target group's health
# check, not just the EC2 status check. If an instance is terminated, fails its
# status check, or stops serving HTTP 200, the ASG terminates it and launches a
# replacement automatically to restore desired_capacity.
###############################################################################

resource "aws_autoscaling_group" "this" {
  name_prefix = "${var.name_prefix}-asg-"

  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.this.arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  # Instances are spread evenly across every subnet listed in
  # vpc_zone_identifier, which is one subnet per AZ, so losing an AZ cannot
  # take out the tier. This balancing is ASG default behaviour.

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  # Rolling replacement when the launch template changes, keeping the tier
  # available throughout.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = tostring(var.health_check_grace_period)
    }
  }

  # Wait for instances to pass the ELB health check before apply returns.
  wait_for_capacity_timeout = "10m"
  min_elb_capacity          = var.min_size

  dynamic "tag" {
    for_each = {
      Name = "${var.name_prefix}-web"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true

    # desired_capacity may legitimately drift if scaling policies are added
    # later; ignoring it keeps `terraform plan` clean.
    ignore_changes = [desired_capacity]
  }

  depends_on = [aws_lb_listener.http]
}
