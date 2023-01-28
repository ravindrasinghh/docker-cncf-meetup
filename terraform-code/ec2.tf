resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
locals {
  key_name = "env:/${var.env}/ssh-keys/${var.env}-meetup-key.pem"
}
resource "aws_s3_object" "tls_key_bucket_object" {
  key     = local.key_name
  bucket  = "ravindra-test-bucket-v2"
  content = tls_private_key.tls.private_key_pem
}

resource "aws_key_pair" "meetup" {
  key_name   = "${var.env}-meetup-key"
  public_key = tls_private_key.tls.public_key_openssh
}


resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.env}-${local.project}-ecs-asg"
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = [for value in aws_subnet.public_subnet : value.id]
  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = aws_launch_template.ecs_launch_template.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
  }

  tag {
    key                 = "env"
    value               = "app"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.env}-${local.project}-ecs-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  name = "${var.env}-${local.project}-ecs-launch-template"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      encrypted   = true
      volume_type = "gp3"
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.meetup.key_name
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  user_data              = filebase64("./ecs_userdata.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-${local.project}-ecs-node"
      env  = "app"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.env}-${local.project}-ecs-node"
      env  = "app"
    }
  }
}

resource "aws_security_group" "server_sg" {
  name                   = "${var.env}-${local.project}-server-sg"
  vpc_id                 = aws_vpc.main.id
  description            = "${var.env}-${local.project}-server-sg"
  revoke_rules_on_delete = true
  tags = {
    Name = "${var.env}-${local.project}-server-sg"
  }
  dynamic "ingress" {
    for_each = var.server_ingress_rules
    content {
      protocol        = ingress.value["protocol"]
      cidr_blocks     = ingress.value["cidr_blocks"]
      from_port       = ingress.value["from_port"]
      to_port         = ingress.value["to_port"]
      security_groups = ingress.value["security_groups"]

    }
  }
  dynamic "egress" {
    for_each = var.server_egress_rules
    content {
      protocol        = egress.value["protocol"]
      cidr_blocks     = egress.value["cidr_blocks"]
      from_port       = egress.value["from_port"]
      to_port         = egress.value["to_port"]
      security_groups = egress.value["security_groups"]
    }
  }
}
