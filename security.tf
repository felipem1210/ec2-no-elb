resource "aws_security_group" "ec2_sg" {
  name        = "${var.tags["prefix"]}-${var.tags["role"]}-ec2"
  vpc_id      = var.vpc_id
  description = "${var.tags["role"]} EC2 Instances Service SG"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.tags["prefix"]}-${var.tags["role"]}-ec2"
    },
  )
}

resource "aws_security_group" "ec2_ssh" {
  name        = "${var.tags["prefix"]}-${var.tags["role"]}-ec2-ssh"
  vpc_id      = var.vpc_id
  description = "SSH to ${var.tags["role"]} EC2 Instances"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.tags["prefix"]}-${var.tags["role"]}-ec2-ssh"
    },
  )
}

# Outbound Rules
resource "aws_security_group_rule" "ec2_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ssh_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_ssh.id
}

