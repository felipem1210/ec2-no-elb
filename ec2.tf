#IAM ROLE
resource "aws_iam_instance_profile" "iam_profile" {
  name = "${var.tags["prefix"]}-${var.tags["role"]}-${replace(uuid(), "-", "")}"
  role = module.iam_role.role_id

  lifecycle {
    ignore_changes = [name]
  }
}


#LAUNCH CONFIG
resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "${var.tags["prefix"]}-${var.tags["role"]}-"
  image_id                    = var.launch_config_image_id
  instance_type               = var.launch_config_instance_type
  iam_instance_profile        = aws_iam_instance_profile.iam_profile.name
  key_name                    = var.launch_config_key_name
  security_groups             = [aws_security_group.ec2_sg.id, aws_security_group.ec2_ssh.id]
  user_data                   = var.additional_user_data
  associate_public_ip_address = var.launch_config_associate_public_ip_address
  enable_monitoring           = var.launch_config_enable_monitoring

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      iam_instance_profile,
    ]
  }

  root_block_device {
    volume_type = var.launch_config_root_block_device_volume_type
    volume_size = var.launch_config_root_block_device_volume_size
  }

  ebs_optimized = var.launch_config_ebs_optimized
  
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      no_device             = lookup(ebs_block_device.value, "no_device", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", 8)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp2")
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "${var.tags["prefix"]}-${var.tags["role"]}"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = var.asg_ec2_subnet_ids
  launch_configuration      = aws_launch_configuration.launch_config.name
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type

  target_group_arns = var.asg_target_group_arns

  depends_on = [aws_launch_configuration.launch_config]

  lifecycle {
    ignore_changes = [
      name,
    ]
    create_before_destroy = true
  }
  
  dynamic "tag" {
    for_each = var.asg_tag_names
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "scale_in" {
  count                  = var.asg_schedule_scale_in_recurrence != "" ? 1 : 0
  scheduled_action_name  = "${var.tags["prefix"]}-${var.tags["role"]}-scheduled-scale-in"
  min_size               = var.asg_schedule_scale_in_min_size
  max_size               = var.asg_schedule_scale_in_max_size
  desired_capacity       = var.asg_schedule_scale_in_desired_capacity
  recurrence             = var.asg_schedule_scale_in_recurrence
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

resource "aws_autoscaling_schedule" "scale_out" {
  count                  = var.asg_schedule_scale_out_recurrence != "" ? 1 : 0
  scheduled_action_name  = "${var.tags["prefix"]}-${var.tags["role"]}-scheduled-scale-out"
  min_size               = var.asg_schedule_scale_out_min_size
  max_size               = var.asg_schedule_scale_out_max_size
  desired_capacity       = var.asg_schedule_scale_out_desired_capacity
  recurrence             = var.asg_schedule_scale_out_recurrence
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

