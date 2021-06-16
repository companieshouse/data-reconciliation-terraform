output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.ecs-cluster.arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.data-reconciliation-task-definition.arn
}

output "security_group_id" {
  description = "The ID of the security group defined for ECS"
  value       = aws_security_group.data-reconciliation-security-group.id
}
