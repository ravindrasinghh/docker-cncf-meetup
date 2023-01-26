resource "aws_ecs_task_definition" "demo-service" {
  family                   = "demo-taskdefination"
  requires_compatibilities = ["${var.compatibility}"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([
    {
      "name" : "demo-service",
      "image" : "672199041248.dkr.ecr.us-west-2.amazonaws.com",
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${var.env}-${local.project}/ecs-demo-taskdefination",
          "awslogs-region" : "ap-south-1",
          "awslogs-stream-prefix" : "demo-service"
        }
      },
      "memory" : 1024,
      "network_mode" : "bridge",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 0,
          "protocol" : "tcp"
        }
      ]
    }
  ])
}
resource "aws_appautoscaling_target" "demo-service_target" {
  max_capacity       = 0
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.demo-service.name}"
  role_arn           = data.aws_iam_role.ecs-autoscale.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_policy" "demo-service_policy" {
  name               = "${aws_ecs_service.demo-service.name}-scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.demo-service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.demo-service_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.demo-service_target.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_ecs_service" "demo-service" {
  name                               = "demo-service"
  cluster                            = aws_ecs_cluster.ecs_cluster.arn
  task_definition                    = aws_ecs_task_definition.demo-service.arn
  launch_type                        = "EC2"
  desired_count                      = 1
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

}
