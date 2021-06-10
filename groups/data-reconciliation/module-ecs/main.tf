resource "aws_security_group" "data-reconciliation-security-group" {
  name = "data-reconciliation-ecs"
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
    Name = "data-reconciliation-ecs"
    Environment = "tbirds1"
    Service = "data-reconciliation"
  }
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "data-reconciliation-tbirds1-cluster"
}

resource "aws_ecs_task_definition" "data-reconciliation-task-definition" {
  family = "tbirds1-data-reconciliation"
  execution_role_arn = var.role_arn
  task_role_arn = var.role_arn
  container_definitions = templatefile(var.template_file, var.task_definition_parameters)
  network_mode = "awspvc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.cpu_units
  memory = var.memory
}