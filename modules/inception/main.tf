locals {
  # We need these with referenceable keys for lifecycles
  data_octopus_environments = {
    for element in data.octopusdeploy_environments.all.environments : 
    element.name => element
  }
}
#All envs resource
resource "octopusdeploy_user_role" "developers" {
  name        =  var.environment
  description = "Responsible for all development-related operations."
  granted_space_permissions = [
    "DeploymentCreate",
    "DeploymentDelete",
    "DeploymentView",
    "EnvironmentView",
    "LifecycleView",
    "ProcessView",
    "ProjectGroupView",
    "ProjectView",
    "ReleaseView",
    "TaskView",
    "TenantView",
  ]
}
#One env resource only
resource "octopusdeploy_project_group" "project_group" {
  count = var.create_space ? 1 : 0
  name     = var.octopus_project_group_name
  space_id = octopusdeploy_space.main[0].id
}

#One env resource only
resource "octopusdeploy_space" "main" {
  count = var.create_space ? 1 : 0
  name                 = var.octopus_project_group_name
  is_default           = false
  space_managers_teams = ["teams-administrators", "teams-managers"]
}

#All envs resource
resource "octopusdeploy_environment" "main" {
  name                         = var.environment
  space_id                     = var.create_space ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id
  allow_dynamic_infrastructure = false
  use_guided_failure           = false
}
#One env resource only
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
