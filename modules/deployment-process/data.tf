locals {
  nr_entity_prefix = var.newrelic_resource_name_prefix != "" ? format("%s-", var.newrelic_resource_name_prefix) : ""
  nr_entity_suffix = var.newrelic_resource_name_suffix != "" ? format("-%s", var.newrelic_resource_name_suffix) : ""

  # Provider is not able to search only one pool with the name, so we need this hack to search it ourselves
  data_worker_pool  = { for worker in data.octopusdeploy_worker_pools.all.worker_pools : worker.name => worker }["${var.octopus_project_group_name}-workers-Ubuntu"]
  data_all_projects = { for project in data.octopusdeploy_projects.all.projects : project.name => project }

}

data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = var.octopus_space_id
}

data "octopusdeploy_environments" "current" {
  name     = var.environment
  space_id = var.octopus_space_id
  take     = 1
}

data "octopusdeploy_project_groups" "all" {
  partial_name = var.octopus_project_group_name
  take         = 1
  space_id     = var.octopus_space_id
}

data "octopusdeploy_machine_policies" "default" {
  partial_name = "Default"
  space_id     = var.octopus_space_id
}

data "octopusdeploy_feeds" "current" {
  partial_name = var.octopus_github_feed_name
  space_id     = var.octopus_space_id
}

data "octopusdeploy_projects" "all" {
  space_id = var.octopus_space_id
}

data "octopusdeploy_worker_pools" "all" {
  space_id = var.octopus_space_id
}

data "newrelic_entity" "this" {
  for_each = var.enable_newrelic ? var.projects : {}
  name   = "${local.nr_entity_prefix}${each.key}${local.nr_entity_suffix}"
}