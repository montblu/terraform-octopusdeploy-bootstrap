data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = var.octopus_space_id
}

data octopusdeploy_environments "current"{
  name     = var.environment
  space_id = var.octopus_space_id
}

data "octopusdeploy_machine_policies" "default" {
  partial_name = "Default"
}

data "octopusdeploy_feeds" "GitHub" {
  feed_type    = "Docker"
  partial_name = var.octopus_dockerhub_feed_name
}