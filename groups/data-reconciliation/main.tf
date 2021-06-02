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
  stack_name = "data-reconciliation"
  stack_fullname = "${local.stack_name}-stack"
  security_group_name = "${local.stack_name}-ecs"
  ecs_service_name = "${var.environment}-${local.stack_name}"
  name_prefix = "${local.stack_name}-${var.environment}"
  task_config_file = "${path.root}/task-definition.tmpl"
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
    company_count_crontab = var.company_count_crontab
    company_collection_crontab = var.company_collection_crontab
    dsq_officer_collection_crontab = var.dsq_officer_collection_crontab
    company_collection_mongo_primary_crontab = var.company_collection_mongo_primary_crontab
    company_collection_mongo_alpha_crontab = var.company_collection_mongo_alpha_crontab
    company_name_mongo_primary_crontab = var.company_name_mongo_primary_crontab
    company_name_mongo_alpha_crontab = var.company_name_mongo_alpha_crontab
    company_status_mongo_primary_crontab = var.company_status_mongo_primary_crontab
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

module "ecs-cluster" {
  source = "git::git@github.com:companieshouse/terraform-library-ecs-cluster.git?ref=1.1.1"
  stack_name = local.stack_name
  name_prefix = local.name_prefix
  environment = var.environment
  vpc_id = data.terraform_remote_state.networks.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networks.outputs.application_ids
  ec2_key_pair_name = var.ec2_key_pair_name
  ec2_instance_type = var.ec2_instance_type
  ec2_image_id = var.ec2_image_id
  asg_max_instance_count = 1
  asg_min_instance_count = 1
  asg_desired_instance_count = 1
}

resource "aws_security_group" "data-reconciliation-security-group" {
  name = local.security_group_name
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
    Name = local.security_group_name
    Environment = var.environment
    Service = local.stack_name
  }
}

resource "aws_ecs_task_definition" "data-reconciliation-task-definition" {
  family = local.ecs_service_name
  execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
  container_definitions = templatefile(local.task_config_file, local.ecs_task_config)
}

resource "aws_ecs_service" "data-reconciliation-ecs-service" {
  name = local.ecs_service_name
  cluster = module.ecs-cluster.ecs_cluster_id
  task_definition = aws_ecs_task_definition.data-reconciliation-task-definition.arn
  desired_count = 1
}
