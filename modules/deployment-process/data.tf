locals {
  nr_entity_prefix = var.newrelic_resource_name_prefix != "" ? format("%s-", var.newrelic_resource_name_prefix) : ""
  nr_entity_suffix = var.newrelic_resource_name_suffix != "" ? format("-%s", var.newrelic_resource_name_suffix) : ""

  # Provider is not able to search only one pool with the name, so we need this hack to search it ourselves
  data_worker_pool = { for worker in data.octopusdeploy_worker_pools.all.worker_pools : worker.name => worker }["${var.octopus_project_group_name}-workers-Ubuntu"]
  data_all_projects = var.create_global_resources ? {
    for project in octopusdeploy_project.all : project.name => project } : {
    for project in data.octopusdeploy_projects.all.projects : project.name => project
  }

}

data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = var.octopus_space_id
  take     = 9999 # non-documented defaults to 10
}

data "octopusdeploy_environments" "current" {
  name     = var.environment
  space_id = var.octopus_space_id
  take     = 1
}

data "octopusdeploy_project_groups" "default" {
  partial_name = var.octopus_project_group_name
  take         = 1
  space_id     = var.octopus_space_id
}
moved {
  from = data.octopusdeploy_project_groups.all # <= v3.2.1
  to   = data.octopusdeploy_project_groups.default
}

data "octopusdeploy_machine_policies" "default" {
  partial_name = "Default"
  space_id     = var.octopus_space_id
  take         = 1
}

data "octopusdeploy_feeds" "current" {
  partial_name = var.octopus_github_feed_name
  space_id     = var.octopus_space_id
  take         = 1
}

data "octopusdeploy_projects" "all" {
  space_id = var.octopus_space_id
  take     = 9999 # non-documented defaults to 10
}

data "octopusdeploy_worker_pools" "all" {
  space_id = var.octopus_space_id
  take     = 9999 # non-documented defaults to 10
}

data "env_sensitive" "octopus_api_key" {
  id       = "OCTOPUS_APIKEY"
  required = false # (optional) plan will error if not found
}