output "task_execution_role_arn" {
  description = "IAM role for ecs task definition"
  value = aws_iam_role.ecs-role.arn
}

output "event_target_role_arn" {
  description = "IAM role for cloudwatch events target resource"
  value = aws_iam_role.cloudwatch-role.arn
}

output "access_key_id" {
  description = "Access key that will be used to connect to S3"
  value = aws_iam_access_key.iam-user.id
}

output "secret_access_key" {
  description = "Secret access key that will be used to connect to S3"
  value = aws_iam_access_key.iam-user.secret
}