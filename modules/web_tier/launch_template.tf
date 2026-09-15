###############################################################################
# Launch template
#
# user_data is rendered from a template so the same module supports both the
# native NGINX path and the optional container path.
###############################################################################

locals {
  user_data = templatefile("${path.module}/templates/user-data.sh.tftpl", {
    enable_container_mode = var.enable_container_mode
    container_image       = var.container_image
    environment           = var.environment
    project               = var.name_prefix
  })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.instance_security_group_id]
    delete_on_termination       = true
  }

  # IMDSv2 required - blocks the SSRF class of credential theft.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = false # detailed monitoring is chargeable; basic is sufficient here
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}-web"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.name_prefix}-web-root"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-lt"
  }
}
