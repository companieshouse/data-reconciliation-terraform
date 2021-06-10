# Task startup
resource "aws_cloudwatch_event_rule" "ecs-startup" {
  name = "data-reconciliation-tbirds1"
  schedule_expression = var.startup_expression
  tags = {
    Name = "data-reconciliation-ecs"
    Environment = "tbirds1"
    Service = "data-reconciliation"
  }
}

resource "aws_cloudwatch_event_target" "ecs-startup" {
  rule = aws_cloudwatch_event_rule.ecs-startup.id
  arn = var.ecs_cluster_arn
  role_arn = var.role_arn
  ecs_target {
    group = "tbirds1-data-reconciliation"
    task_definition_arn = var.ecs_task_arn
    launch_type = "FARGATE"
    task_count = 1
    network_configuration {
      subnets = [var.subnets]
      security_groups = [var.security_groups]
      assign_public_ip = false
    }
  }
}

# Task shutdown
resource "aws_cloudwatch_event_rule" "ecs-shutdown" {
  name = "data-reconciliation-tbirds1"
  schedule_expression = var.shutdown_expression
  tags = {
    Name = "data-reconciliation-ecs"
    Environment = "tbirds1"
    Service = "data-reconciliation"
  }
}

resource "aws_cloudwatch_event_target" "ecs-shutdown" {
  rule = aws_cloudwatch_event_rule.ecs-shutdown.id
  arn = var.ecs_cluster_arn
  role_arn = var.role_arn
  ecs_target {
    group = "tbirds1-data-reconciliation"
    task_definition_arn = var.ecs_task_arn
    launch_type = "FARGATE"
    task_count = 0
    network_configuration {
      subnets = [var.subnets]
      security_groups = [var.security_groups]
      assign_public_ip = false
    }
  }
}