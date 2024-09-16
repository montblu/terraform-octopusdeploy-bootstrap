data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = var.octopus_space_id
}

data "octopusdeploy_environments" "current" {
  name     = var.octopus_environment
  space_id = var.octopus_space_id
}

data "octopusdeploy_machine_policies" "default" {
  partial_name = "Default"
  space_id     = var.octopus_space_id
}

data "octopusdeploy_feeds" "current" {
  partial_name = var.octopus_github_feed_name
  space_id     = var.octopus_space_id
}

data "octopusdeploy_worker_pools" "all" {
  space_id = var.octopus_space_id

  depends_on = [
    octopusdeploy_dynamic_worker_pool.ubuntu
  ]
}

# Provider is not able to search only one pool with the name, so we need this hack to search it ourselves
locals {
  data_worker_pool = {for worker in data.octopusdeploy_worker_pools.all.worker_pools : worker.name => worker}["${var.octopus_project_group_name}-workers-Ubuntu"]
}