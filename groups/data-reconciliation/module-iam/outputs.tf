output "task_execution_role_arn" {
  description = "IAM role for ecs task definition"
  value = aws_iam_role.ecs-role.arn
}

output "event_target_role_arn" {
  description = "IAM role for cloudwatch events target resource"
  value = aws_iam_role.cloudwatch-role.arn
}