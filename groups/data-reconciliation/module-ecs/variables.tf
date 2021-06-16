variable "role_arn" {
  description = "The ARN of the IAM role."
  type        = string
}

variable "task_definition_parameters" {
  description = "Environment variables and container properties for ECS task definition"
  type        = map(any)
}

variable "cpu_units" {
  description = "The number of CPU units that will be allocated to the ECS task definition"
  type        = number
}

variable "memory" {
  description = "The amount of memory required by the ECS task definition"
  type        = number
}

variable "security_group_name" {
  description = "The name that will be allocated to the data reconciliation security group"
  type        = string
}

variable "environment" {
  description = "The name of the environment that the data reconciliation app will be deployed to"
  type        = string
}

variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "deployment_name" {
  description = "A name identifying the application on the environment that it is deployed to"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC that the security group will be part of"
  type        = string
}