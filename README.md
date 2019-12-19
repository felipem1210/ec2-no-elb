# ec2-no-elb

## Overview

Terraform module to create an ASG EC2 instances stack with no ELB, SGs and common IAM Role.

## Dependencies

* tf-aws-iam-role-common (>=1.0.1) - For IAM Common Role creation
* tf-aws-cloud-init (5.0.2)

## Usage

```
module "ec2-main" {
  source = "./modules/tf-aws-ec2-no-elb"
  vpc_id = module.vpc-main.vpc_id

  launch_config_image_id                    = "ami-02013ed1a71752ea7"
  launch_config_instance_type               = "t2.micro"
  launch_config_key_name                    = aws_key_pair.ec2.key_name
  launch_config_associate_public_ip_address = false
  launch_config_enable_monitoring           = false

  launch_config_root_block_device_volume_size = 80
  launch_config_root_block_device_volume_type = "gp2"

  asg_min_size         = 1
  asg_max_size         = 1
  asg_desired_capacity = 1
  asg_ec2_subnet_ids   = [module.vpc-main.public_subnet_ids[0][1]]


  ebs_block_device = [{
      device_name           = "/dev/sd1"
      delete_on_termination = false
      encrypted             = true
      volume_size           =  55
      volume_type           = "gp2"
    },
    {
      device_name           = "/dev/sdn"
      delete_on_termination = false
      encrypted             = true
      volume_size           = 75
      volume_type           = "gp2"
    }
  ]

  asg_tag_names = {
    Name          = "${var.tags["prefix"]}-${var.tags["role"]}-instance"
    role          = "used-role"
    prefix        = "app-prefix"
    tag0          = "tag0"
    tag1          = "tag1"
    tagx          = "tagx"
    tag_rand_name = "rand_value"
  }
  tags = var.tags
}
```

## Scheduled scale in and out instances

Using `asg_schedule_scale_in_recurrence` and `asg_schedule_scale_out_recurrence` implementors of the module could perform a variety of actions to auto increase of reduce the ASG's instances, for example, for non-production instances one could say:

- Scale in all instances only in weekdays during office hours:
- Scale out all instances during evenings and weekends:


```
  module "my_cluster" {
    source  = "../tf-aws-ec2-no-elb"

    vpc_id                                      = "vpc-1234d"

    launch_config_image_id                      = "ami-33554b"
    launch_config_instance_type                 = "t2.large"
    launch_config_key_name                      = "my-pem-name"
    launch_config_associate_public_ip_address   = false
    launch_config_enable_monitoring             = false
    launch_config_root_block_device_volume_size = 80

    asg_min_size                                = 1
    asg_max_size                                = 1
    asg_desired_capacity                        = 1
    asg_ec2_subnet_ids                          = ["subnet-12344"]

    tags                                        = "${var.tags}"

    # scale IN every weekday from Mon to Fri at 7 AM
    asg_schedule_scale_out_min_size              = 1
    asg_schedule_scale_out_max_size              = 1
    asg_schedule_scale_out_desired_capacity      = 1
    asg_schedule_scale_out_recurrence            = "0 10 * * 1-5"

    # scale OUT every weekday from Mon to Fri at 23 PM
    asg_schedule_scale_in_min_size              = 0
    asg_schedule_scale_in_max_size              = 1
    asg_schedule_scale_in_desired_capacity      = 0
    asg_schedule_scale_in_recurrence            = "0 2 * * 2-6"
  }
```

## Tags

Implement by defining a  `asg_tags_name` in the module invocation, the new terraform version lets you map all the tags you put in there to the asg tags. `role` and `prefix` are required by the module, althogh you can leave the map empty and define them separately (not recommended).

```
  asg_tag_names = {
    Name="name-to-use"
    role="used-role"
    prefix="app-prefix"
    tag_x="some_value"
  }
```

## Security
* Please note the instances will only have basic output for security (output everywhere), if you want to add inbound rules on the instances SGs you will have to implement it outside the module.

```
resource "aws_security_group_rule" "sg_inbound" {
    type              = "ingress"
    from_port         = 8080
    to_port           = 8080
    protocol          = "TCP"
    cidr_blocks       = [ "0.0.0.0/0" ]
    security_group_id = "${module.my_cluster.ec2_sg_id}"
}

resource "aws_security_group_rule" "ssh_ec2_inbound" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "TCP"
    cidr_blocks       = [ "0.0.0.0/0" ]
    security_group_id = "${module.my_cluster.ec2_ssh_sg_id}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_user_data | Contains additional code (BASH Snippet) to append into the cloud-init template | string | `` | no |
| asg_desired_capacity | The number of Amazon EC2 instances that should be running in the group | string | `2` | no |
| asg_ec2_subnet_ids | A list of subnet IDs to launch resources in | list | - | yes |
| asg_health_check_grace_period | Time (in seconds) after instance comes into service before checking health | string | `300` | no |
| asg_health_check_type | Controls how health checking is done. Should be allways 'EC2' as this module does not have ELB | string | `EC2` | no |
| asg_max_size | The maximum size of the auto scale group | string | `2` | no |
| asg_min_size | The minimum size of the auto scale group | string | `2` | no |
| asg_schedule_scale_in_desired_capacity | The number of EC2 instances that should be running in the group. Defaults to -1 which won't change the maximum size at the scheduled time. | string | `-1` | no |
| asg_schedule_scale_in_max_size | The maximum size for the Auto Scaling group. Defaults to -1 which won't change the maximum size at the scheduled time. | string | `-1` | no |
| asg_schedule_scale_in_min_size | The minimum size for the Auto Scaling group. Defaults to -1 which won't change the minimum size at the scheduled time. | string | `-1` | no |
| asg_schedule_scale_in_recurrence | The time when recurring future actions will start. Start time is specified by the user following the Unix cron syntax format. | string | `` | no |
| asg_schedule_scale_out_desired_capacity | The number of EC2 instances that should be running in the group. Defaults to -1 which won't change the maximum size at the scheduled time. | string | `-1` | no |
| asg_schedule_scale_out_max_size | The maximum size for the Auto Scaling group. Default 0. Defaults to -1 which won't change the maximum size at the scheduled time. | string | `-1` | no |
| asg_schedule_scale_out_min_size | The minimum size for the Auto Scaling group. Default 0. Defaults to -1 which won't change the minimum size at the scheduled time. | string | `-1` | no |
| asg_schedule_scale_out_recurrence | The time when recurring future actions will start. Start time is specified by the user following the Unix cron syntax format. | string | `` | no |
| asg_tag_names | A mapping of tag names to assign to the ASG resource. Should match the naming of the keys in tags variable | map | - | yes |
| asg_target_group_arns | A list of aws_alb_target_group ARNs, for use with Application Load Balancing | list | `<list>` | no |
| ebs_block_device | A mapping of the block devices that you want to attach to the ASG and the instances | list(map(string)) | - | no |
| ebs_block_device.device_name | The device name for a specific volume (e.g. `/dev/sda`). Be sure to use a name convention to designating the name | string | - | yes |
| ebs_block_device.volume_type | The type of volume. Can be "standard", "gp2", or "io1" | string | gp2 | no |
| ebs_block_device.volume_size | The size of the volume in gigabytes | number | 8 | no |
| ebs_block_device.encrypted | Whether the volume should be encrypted or not. Do not use this option if you are using snapshot_id as the encrypted flag will be determined by the snapshot | bool | true | no |
| ebs_block_device.delete_on_termination | Whether the volume should be destroyed on instance termination  | bool | true | no |
| ebs_block_device.iops| The amount of provisioned IOPS. This must be set with a volume_type of "io1" | string | null | no |
| ebs_block_device.no_device| Suppresses the specified device included in the block device mapping of the AMI | string | null | no |
| ebs_block_device.snapshot_id| The Snapshot ID to mount | string | null | no |
| cloud_init_config_manager_agent_version | Version of the config manager agent package to be installed. If empty will install the latest version | string | `` | no |
| cloud_init_distro | The OS distribution name | string | `ubuntu` | no |
| cloud_init_template_prefix | The cloud init template prefix used to build the name of the template | string | `common` | no |
| launch_config_associate_public_ip_address | Associate a public ip address with an instance in a VPC | string | `false` | no |
| launch_config_ebs_block_devices | Additional EBS block devices to attach to the instance. Refer to documentation on how to use this variable | string | `<list>` | no |
| launch_config_ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | string | `false` | no |
| launch_config_enable_monitoring | Enables/disables detailed monitoring | string | `false` | no |
| launch_config_image_id | The EC2 image ID to launch | string | - | yes |
| launch_config_instance_type | The size of instance to launch | string | `t2.micro` | no |
| launch_config_key_name | The key name that should be used for the instance | string | - | yes |
| launch_config_root_block_device_volume_size | The size of the volume in gigabytes | string | `8` | no |
| launch_config_root_block_device_volume_type | The type of volume. Can be 'standard', 'gp2', or 'io1' | string | `gp2` | no |
| tags | A mapping of tags to assign to the resource | map | - | yes |
| vpc_id | The ID of the VPC | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling_group_name | The name of the autoscale group |
| ec2_sg_id | The ID of the EC2 Security Group |
| ec2_ssh_sg_id | The ID of the EC2 SSH Security Group |
| iam_role_id | The Amazon Resource Name (ARN) specifying the role |

