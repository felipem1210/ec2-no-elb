# Cloud Init
variable "additional_user_data" {
  description = "Contains additional code (BASH Snippet) to append into the cloud-init template"
  default     = ""
}

variable "cloud_init_distro" {
  description = "The OS distribution name"
  default     = "amazon_linux"
}

variable "cloud_init_template_prefix" {
  description = "The cloud init template prefix used to build the name of the template"
  default     = "ec2"
}

# Launch Configuration
variable "launch_config_image_id" {
  description = "The EC2 image ID to launch"
}

variable "launch_config_instance_type" {
  description = "The size of instance to launch"
  default     = "t2.micro"
}

variable "launch_config_key_name" {
  description = "The key name that should be used for the instance"
}

variable "launch_config_associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default     = false
}

variable "launch_config_enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  default     = false
}

# Root Device

variable "launch_config_root_block_device_volume_type" {
  description = "The type of volume. Can be 'standard', 'gp2', or 'io1'"
  default     = "gp2"
}

variable "launch_config_root_block_device_volume_size" {
  description = "The size of the volume in gigabytes"
  default     = 8
}

# EBS block devices

variable "launch_config_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}
variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}
# Auto Scaling Group
variable "asg_min_size" {
  description = "The minimum size of the auto scale group"
  default     = 2
}

variable "asg_max_size" {
  description = "The maximum size of the auto scale group"
  default     = 2
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  default     = 2
}

variable "asg_ec2_subnet_ids" {
  description = "A list of subnet IDs to launch resources in"
}

variable "asg_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
}

variable "asg_health_check_type" {
  description = "Controls how health checking is done. Should be allways 'EC2' as this module does not have ELB"
  default     = "EC2"
}

variable "asg_schedule_scale_out_min_size" {
  description = "The minimum size for the Auto Scaling group. Default 0. Defaults to -1 which won't change the minimum size at the scheduled time."
  default     = -1
}

variable "asg_schedule_scale_out_max_size" {
  description = "The maximum size for the Auto Scaling group. Default 0. Defaults to -1 which won't change the maximum size at the scheduled time."
  default     = -1
}

variable "asg_schedule_scale_out_desired_capacity" {
  description = "The number of EC2 instances that should be running in the group. Defaults to -1 which won't change the maximum size at the scheduled time."
  default     = -1
}

variable "asg_schedule_scale_out_recurrence" {
  description = "The time when recurring future actions will start. Start time is specified by the user following the Unix cron syntax format."
  default     = ""
}

variable "asg_schedule_scale_in_min_size" {
  description = "The minimum size for the Auto Scaling group. Defaults to -1 which won't change the minimum size at the scheduled time."
  default     = -1
}

variable "asg_schedule_scale_in_max_size" {
  description = "The maximum size for the Auto Scaling group. Defaults to -1 which won't change the maximum size at the scheduled time."
  default     = -1
}

variable "asg_schedule_scale_in_desired_capacity" {
  description = "The number of EC2 instances that should be running in the group. Defaults to -1 which won't change the maximum size at the scheduled time."
  default     = -1
}

variable "asg_schedule_scale_in_recurrence" {
  description = "The time when recurring future actions will start. Start time is specified by the user following the Unix cron syntax format."
  default     = ""
}

variable "asg_tag_names" {
  description = "A mapping of tag names to assign to the ASG resource. Should match the naming of the keys in tags variable"
  type        = map(string)
}

variable "asg_target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  type        = list(string)
  default     = []
}

# Common variables
variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}

