provider "aws" {
  region = var.aws_region
  version = "~> 2.50.0"
}

provider "vault" {
  auth_login {
    path = "auth/userpass/login/${var.vault_username}"
    parameters = {
      password = var.vault_password
    }
  }
}

terraform {
  backend "s3" {}
}

locals {
  stack_name = "data-reconciliation" # the service name
  stack_fullname = "${local.stack_name}-stack"
  name_prefix = "${local.stack_name}-${var.environment}"
  security_group_name = "${local.name_prefix}-ecs"
}

data "terraform_remote_state" "networks" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "${var.state_prefix}/${var.deploy_to}/${var.deploy_to}.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "services-stack-configs" {
  backend = "s3"
  config = {
    bucket = var.aws_bucket # aws-common-infrastructure-terraform repo uses the same remote state bucket
    key    = "aws-common-infrastructure-terraform/common-${var.aws_region}/services-stack-configs.tfstate"
    region = var.aws_region
  }
}

data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.environment}/${local.stack_fullname}"
}

module "secrets" {
  source = "./module-secrets"
  stack_name = local.stack_name
  name_prefix = local.name_prefix
  environment = var.environment
  kms_key_id = data.terraform_remote_state.services-stack-configs.outputs.services_stack_configs_kms_key_id
  secrets = data.vault_generic_secret.secrets.data
}

resource "aws_s3_bucket" "data-reconciliation-bucket" {
  bucket = local.name_prefix
  acl = "private"
}

locals {
  ecs_task_config = merge({
    aws_region = var.aws_region
    service_name = local.stack_name
    name_prefix = local.name_prefix
    company_count_delay = var.company_count_delay
    company_number_mongo_oracle_delay = var.company_number_mongo_oracle_delay
    company_number_mongo_primary_delay = var.company_number_mongo_primary_delay
    company_number_mongo_alpha_delay = var.company_number_mongo_alpha_delay
    disqualification_delay = var.disqualification_delay
    company_name_mongo_primary_delay = var.company_name_mongo_primary_delay
    company_name_mongo_alpha_delay = var.company_name_mongo_alpha_delay
    company_status_mongo_primary_delay = var.company_status_mongo_primary_delay
    company_status_mongo_alpha_delay = var.company_status_mongo_alpha_delay
    company_status_mongo_oracle_delay = var.company_status_mongo_oracle_delay
    company_profile_db = var.company_profile_db
    company_profile_collection = var.company_profile_collection
    dsq_officer_db = var.dsq_officer_db
    dsq_officer_collection = var.dsq_officer_collection
    jdbc_driver = var.jdbc_driver
    mongodb_read_preference = var.mongodb_read_preference
    elasticsearch_primary_segments = var.elasticsearch_primary_segments
    elasticsearch_primary_slice_size = var.elasticsearch_primary_slice_size
    elasticsearch_primary_slice_field = var.elasticsearch_primary_slice_field
    elasticsearch_alpha_segments = var.elasticsearch_alpha_segments
    elasticsearch_alpha_slice_size = var.elasticsearch_alpha_slice_size
    elasticsearch_alpha_slice_field = var.elasticsearch_alpha_slice_field
    results_initial_capacity = var.results_initial_capacity
    results_bucket = local.name_prefix
    email_application_id = var.email_application_id
    email_message_id = var.email_message_id
    email_message_type = var.email_message_type
    results_expiry_time_in_millis = var.results_expiry_time_in_millis
    docker_registry = var.docker_registry
    release_version = var.release_version
  }, module.secrets.secrets_arn_map)
}

module "data-reconcilliation-iam" {
  source = "./module-iam"
  deployment_name = local.name_prefix
}

module "data-reconcilliation-ecs" {
  source = "./module-ecs"
  vpc_id = data.terraform_remote_state.networks.outputs.vpc_id
  role_arn = module.data-reconcilliation-iam.task_execution_role_arn
  task_definition_parameters = local.ecs_task_config
  cpu_units = var.cpu_units
  memory = var.memory
  security_group_name = local.security_group_name
  application_name = local.stack_name
  deployment_name = local.name_prefix
  environment = var.environment
}

module "data-reconcilliation-cloudwatch" {
  source = "./module-cloudwatch"
  role_arn = module.data-reconcilliation-iam.event_target_role_arn
  startup_expression = var.startup_expression
  ecs_cluster_arn = module.data-reconcilliation-ecs.ecs_cluster_arn
  ecs_task_arn = module.data-reconcilliation-ecs.ecs_task_definition_arn
  security_groups = [module.data-reconcilliation-ecs.security_group_id]
  subnets = split(",", data.terraform_remote_state.networks.outputs.application_ids)
  application_name = local.stack_name
  deployment_name = local.name_prefix
  environment = var.environment
  security_group_name = local.security_group_name
}