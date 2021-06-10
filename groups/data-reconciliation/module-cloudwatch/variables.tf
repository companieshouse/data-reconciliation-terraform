variable "role_arn" {
  description = "The IAM role for the Cloudwatch event target"
  type = string
}

variable "startup_expression" {
  description = "A cron expression indicating when the ECS task definition should be started"
  type = string
}

variable "shutdown_expression" {
  description = "A cron expression indicating when the ECS task definition should be stopped"
  type = string
}

variable "ecs_cluster_arn" {
  description = "The ECS cluster responsible for running the task definition"
  type = string
}

variable "ecs_task_arn" {
  description = "The ECS task definition that will run the application"
  type = string
}

variable "security_groups" {
  description = "The security groups applicable to the ECS task definition"
  type = set(string)
}

variable "subnets" {
  description = "The subnets associated with the ECS task definition"
  type = set(string)
}
