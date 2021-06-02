# AWS
variable "aws_region" {
  description = "The AWS region for deployment."
  type = string
  default = "eu-west-2"
}

variable "aws_profile" {
  description = "The AWS profile to use for deployment."
  type = string
  default = "development-eu-west-2"
}

variable "aws_bucket" {
  description = "The bucket used to store the current terraform state files."
  type = string
}

variable "remote_state_bucket" {
  description = "Alternative bucket used to store the remote state files from ch-service-terraform"
  type = string
}

variable "ec2_key_pair_name" {
  description = "The key pair for SSH access to ec2 instances in the clusters."
  type = string
}

variable "ec2_instance_type" {
  description = "The instance type for ec2 instances in the clusters."
  type = string
  default = "z1d.large"
}

variable "ec2_image_id" {
  description = "The machine image name for the ECS cluster launch configuration."
  type = string
  default = "ami-007ef488b3574da6b"
}

# Deployment
variable "environment" {
  description = "The environment this stack will be created for."
  type = string
}

variable "deploy_to" {
  description = "Bucket namespace used with remote_state_bucket and state_prefix."
  type = string
}

variable "state_prefix" {
  description = "The bucket prefix used with the remote_state_bucket files."
  type = string
}

variable "docker_registry" {
  description = "The FQDN of the Docker registry."
  type = string
}

variable "release_version" {
  description = "The version of data-reconciliation that will be deployed."
  type = string
}

# Secrets
variable "vault_username" {
  description = "The username used by the Vault provider."
  type = string
}

variable "vault_password" {
  description = "The password used by the Vault provider."
  type = string
}

# App configuration
variable "company_count_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of company counts."
  type = string
}

variable "company_collection_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of company numbers."
  type = string
}

variable "company_collection_mongo_primary_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of company numbers between MongoDB and the Elasticsearch primary index."
  type = string
}

variable "company_collection_mongo_alpha_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of company numbers between MongoDB and the Elasticsearch alpha index."
  type = string
}

variable "dsq_officer_collection_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of disqualified officers."
  type = string
}

variable "company_name_mongo_primary_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of company names between MongoDB and the Elasticsearch primary index."
  type = string
}

variable "company_name_mongo_alpha_crontab" {
  description = "A crontab expression that will be used to trigger a comparison of company names between MongoDB and the Elasticsearch alpha index."
  type = string
}

variable "company_profile_db" {
  description = "The name of the MongoDB database used to store company profile documents."
  type = string
  default = "company_profile"
}

variable "company_profile_collection" {
  description = "The name of the MongoDB collection used to store company profile documents."
  type = string
  default = "company_profile"
}

variable "dsq_officer_db" {
  description = "The name of the MongoDB database used to store disqualification documents."
  type = string
  default = "disqualifications"
}

variable "dsq_officer_collection" {
  description = "The name of the MongoDB collection used to store disqualification documents."
  type = string
  default = "disqualifications"
}

variable "jdbc_driver" {
  description = "The classname of the JDBC driver that will be used to connect to the database."
  type = string
  default = "oracle.jdbc.OracleDriver"
}

variable "mongodb_read_preference" {
  description = "Modifies how MongoDB requests are routed to members of a replica set."
  type = string
  default = "SECONDARY_PREFERRED"
}

variable "elasticsearch_primary_segments" {
  description = "The number of segments scrolling searches will be split into."
  type = number
  default = 3
}

variable "elasticsearch_primary_slice_size" {
  description = "The number of search results that will be fetched in each search request."
  type = number
  default = 500
}

variable "elasticsearch_primary_slice_field" {
  description = "The field that will be used to construct scrolling search slices."
  type = string
  default = "_uid"
}

variable "elasticsearch_alpha_segments" {
  description = "The number of segments scrolling searches will be split into."
  type = number
  default = 3
}

variable "elasticsearch_alpha_slice_size" {
  description = "The number of search results that will be fetched in each search request."
  type = number
  default = 500
}

variable "elasticsearch_alpha_slice_field" {
  description = "The field that will be used to construct scrolling search slices."
  type = string
  default = "_id"
}

variable "results_initial_capacity" {
  description = "The initial size of the collection of results."
  type = number
}

variable "email_application_id" {
  description = "The application ID used by chs-notification-api to render a template containing comparison results."
  type = string
  default = "data_reconciliation.data_reconciliation_email"
}

variable "email_message_id" {
  description = "The message ID used by chs-notification-api to render a template containing comparison results."
  type = string
  default = "data_reconciliation_email_results"
}

variable "email_message_type" {
  description = "The message type used by chs-notification-api to render a template containing comparison results."
  type = string
  default = "data_reconciliation_email_results"
}

variable "results_expiry_time_in_millis" {
  description = "The duration in milliseconds after which results uploaded to S3 can no longer be accessed."
  type = number
}
