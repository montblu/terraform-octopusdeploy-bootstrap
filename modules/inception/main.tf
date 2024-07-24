locals {
  # We need these with referenceable keys for lifecycles
  data_octopus_environments = {
    for element in data.octopusdeploy_environments.all.environments : 
    element.name => element
  }
}

resource "octopusdeploy_project_group" "project_group" {
  count = var.octopus_project_group_name == "" ? 0 : 1
  name     = var.octopus_project_group_name
  space_id = octopusdeploy_space.main[0].id
}

resource "octopusdeploy_space" "main" {
  count = var.octopus_project_group_name == "" ? 0 : 1
  name                 = var.octopus_project_group_name
  is_default           = false
  space_managers_teams = ["teams-administrators", "teams-managers"]
}

resource "octopusdeploy_environment" "main" {
  for_each = toset(var.octopus_environments) 
  name                         = each.key
  space_id                     = octopusdeploy_space.main[0].id
  allow_dynamic_infrastructure = false
  use_guided_failure           = false
}

resource "octopusdeploy_lifecycle" "lifecycles" {

  for_each = {for lifecycle in var.lifecycles : lifecycle.name => lifecycle }

  name        = each.value.name
  description = each.value.description
  space_id    = octopusdeploy_space.main[0].id

  release_retention_policy {
    quantity_to_keep    = each.value.release_retention_policy.quantity_to_keep
    should_keep_forever = each.value.release_retention_policy.should_keep_forever
    unit                = each.value.release_retention_policy.unit
  }

  dynamic "phase" {
    for_each = each.value.phases
    content {
      is_optional_phase                     = phase.value.is_optional_phase
      name                                  = phase.value.name
      minimum_environments_before_promotion = phase.value.minimum_environments_before_promotion
      optional_deployment_targets = [
        for env in phase.value.optional_deployment_targets :
        local.data_octopus_environments[env].id
      ]
    }
  }

  depends_on = [
    octopusdeploy_environment.main
  ]
}
