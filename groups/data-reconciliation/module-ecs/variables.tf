variable "role_arn" {
  description = "The ARN of the IAM role."
  type        = string
}

variable "template_file" {
  description = "The file that will be used to create an ECS task definition"
  type        = string
}

variable "task_definition_parameters" {
  description = "Environment variables and container properties for ECS task definition"
  type        = map
}

variable "cpu_units" {
  description = "The number of CPU units that will be allocated to the ECS task definition"
  type        = number
}

variable "memory" {
  description = "The amount of memory required by the ECS task definition"
  type        = number
}
