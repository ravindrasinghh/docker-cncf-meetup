resource "aws_ecs_cluster" "ecs_cluster" {
  name               = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
    base              = 0
  }
  tags = {
    Name = "${var.env}-${local.project}-cluster"
  }
}
resource "random_id" "server" {
  keepers = {
    ecs_capacity_provider_name = "meetup-capacity-provider"
  }
  byte_length = 4
}


resource "aws_ecs_capacity_provider" "this" {
  name = "${var.env}-${local.project}-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}
