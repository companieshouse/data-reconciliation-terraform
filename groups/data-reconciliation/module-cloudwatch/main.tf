# Task startup
resource "aws_cloudwatch_event_rule" "ecs-startup" {
  name = var.deployment_name
  schedule_expression = var.startup_expression
  tags = {
    Name = var.security_group_name
    Environment = var.environment
    Service = var.application_name
  }
}

resource "aws_cloudwatch_event_target" "ecs-startup" {
  rule = aws_cloudwatch_event_rule.ecs-startup.id
  arn = var.ecs_cluster_arn
  role_arn = var.role_arn
  ecs_target {
    group = var.deployment_name
    task_definition_arn = var.ecs_task_arn
    launch_type = "FARGATE"
    task_count = 1
    network_configuration {
      subnets = var.subnets
      security_groups = var.security_groups
      assign_public_ip = false
    }
  }
}
