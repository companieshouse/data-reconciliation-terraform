variable "deployment_name" {
  description = "A name identifying the deployed service"
  type = string
}

variable "result_bucket_arn" {
  description = "The ARN of the S3 bucket that results will be uploaded to"
  type = string
}

variable "environment" {
  description = "The environment to which the application will be deployed."
  type = string
}

variable "service-name" {
  description = "The name of the service that will be deployed."
  type = string
}