#One env resource only
resource "octopusdeploy_user_role" "developers" {
  count       = var.create_space ? 1 : 0
  name        = "${title(var.octopus_project_group_name)} - Developers"
  description = "Responsible for all development-related operations."
  granted_space_permissions = [
    "AccountView",
    "CertificateView",
    "DeploymentCreate",
    "DeploymentDelete",
    "DeploymentView",
    "EnvironmentView",
    "FeedView",
    "LifecycleView",
    "MachinePolicyView",
    "MachineView",
    "ProcessView",
    "ProjectGroupView",
    "ProjectView",
    "ReleaseView",
    "TaskView",
    "TenantView",
  ]
}
#One env resource only
resource "octopusdeploy_team" "developers" {
  count = var.create_space ? 1 : 0
  name  = "${title(var.octopus_project_group_name)} - Developers"
  user_role {
    space_id     = octopusdeploy_space.main[0].id
    user_role_id = octopusdeploy_user_role.developers[0].id
  }
}
#One env resource only
resource "octopusdeploy_project_group" "project_group" {
  count    = var.create_space ? 1 : 0
  name     = var.octopus_project_group_name
  space_id = octopusdeploy_space.main[0].id
}

#One env resource only
resource "octopusdeploy_space" "main" {
  count                = var.create_space ? 1 : 0
  name                 = var.octopus_project_group_name
  is_default           = false
  space_managers_teams = ["teams-administrators", "teams-managers"]
}

#All envs resource
resource "octopusdeploy_environment" "main" {

  name                         = var.octopus_environment
  space_id                     = var.create_space ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id
  allow_dynamic_infrastructure = false
  use_guided_failure           = false
}
#One env resource only
resource "octopusdeploy_lifecycle" "main" {
  for_each = var.create_space ? { for lifecycle in var.lifecycles : lifecycle.name => lifecycle } : {}

  name        = each.value.name
  description = each.value.description
  space_id    = var.create_space ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id

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
      optional_deployment_targets           = phase.value.optional_deployment_targets
      automatic_deployment_targets          = phase.value.automatic_deployment_targets
    }
  }

  depends_on = [
    octopusdeploy_environment.main
  ]
}

resource "octopusdeploy_docker_container_registry" "github" {
  count = var.create_space ? 1 : 0

  space_id    = octopusdeploy_space.main[0].id
  feed_uri    = "https://ghcr.io"
  name        = var.octopus_github_feed_name
  api_version = "v2"
}
