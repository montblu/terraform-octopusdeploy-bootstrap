
locals {
  octopusdeploy_environments = [for env in var.octopus_environments : data.octopusdeploy_environments.all[env].environments[0].id ]
}

resource "octopusdeploy_project_group" "project_group" {
  name  = var.octopus_group_name
  space_id = octopusdeploy_space.main.id
}

resource "octopusdeploy_space" "main" {
  name       = var.octopus_group_name
  is_default = false
  space_managers_teams = ["teams-administrators","teams-managers"]
}

resource "octopusdeploy_environment" "main" {
  for_each                     = var.octopus_environments    
  name                         = each.key
  allow_dynamic_infrastructure = false
  use_guided_failure           = false
}

data "octopusdeploy_environments" "all" {
  for_each = toset(var.octopus_environments)
  name     = each.key
}

resource "octopusdeploy_lifecycle" "from-stage-to-prod" {

  name        = "${var.octopus_group_name} - from stage to prod"
  description = "This is the main lifecycle used on all envs."

  release_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Days"
  }

  # This 2 phase blocks need to be temporary commented on the 1st terraform apply, sorry...
  # Octopus deployments must be created prior to phases.
  phase {
    name                                  = "Stage"
    minimum_environments_before_promotion = 1
    optional_deployment_targets = [
      data.octopusdeploy_environments.all["stage"].environments[0].id,
      data.octopusdeploy_environments.all["test"].environments[0].id,
    ]
  }

  phase {
    is_optional_phase                     = false
    name                                  = "Production"
    minimum_environments_before_promotion = 1
    optional_deployment_targets = [
      data.octopusdeploy_environments.all["demo"].environments[0].id,
      data.octopusdeploy_environments.all["prod"].environments[0].id,
    ]
  }
  # End of the 2 phase blocks that need to be temporary commented on 1 terraform apply, sorry again...

  depends_on = [
    octopusdeploy_environment.main
  ]
}

resource "octopusdeploy_channel" "single-channel" {

  for_each = var.project_names

  name         = "${var.octopus_group_name} - single channel"
  project_id   = octopusdeploy_project.all[each.key].id
  lifecycle_id = octopusdeploy_lifecycle.from-stage-to-prod[0].id
  is_default   = false

}

resource "octopusdeploy_docker_container_registry" "DockerHub" {

  feed_uri    = "https://index.docker.io"
  name        = var.octopus_dockerhub_feed_name
  api_version = "v1"
}

resource "octopusdeploy_dynamic_worker_pool" "ubuntu" {

  name        = "${var.octopus_group_name}-workers-Ubuntu"
  space_id    = octopusdeploy_space.main.id
  worker_type = "Ubuntu2204"
  is_default  = true
}

resource "octopusdeploy_project" "all" {

  for_each = var.project_names

  space_id                             = octopusdeploy_space.main[0].id
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = octopusdeploy_lifecycle.from-stage-to-prod[0].id
  name                                 = each.key
  project_group_id                     = octopusdeploy_project_group.project_group[0].id
  tenanted_deployment_participation    = "Untenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  depends_on = [
    octopusdeploy_lifecycle.from-stage-to-prod,
    octopusdeploy_project_group.project_group
  ]
}