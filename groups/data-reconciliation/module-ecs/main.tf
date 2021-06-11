resource "aws_security_group" "data-reconciliation-security-group" {
  name = var.security_group_name
  description = "Security group for data reconciliation"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = var.security_group_name
    Environment = var.environment
    Service = var.application_name
  }
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.deployment_name
}

resource "aws_ecs_task_definition" "data-reconciliation-task-definition" {
  family = var.deployment_name
  execution_role_arn = var.role_arn
  task_role_arn = var.role_arn
  cpu = var.cpu_units
  memory = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  container_definitions = templatefile("${path.module}/task-definition.tmpl", var.task_definition_parameters)
}