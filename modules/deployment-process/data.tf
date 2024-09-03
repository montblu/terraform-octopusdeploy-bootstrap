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
}

data "octopusdeploy_feeds" "current" {
  partial_name = var.octopus_github_feed_name
  space_id     = var.octopus_space_id
}
