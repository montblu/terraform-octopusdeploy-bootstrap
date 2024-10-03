data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = var.create_global_resources ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id
  take     = 9999 # non-documented defaults to 10

  depends_on = [
    octopusdeploy_environment.main
  ]
}

data "octopusdeploy_project_groups" "default" {
  partial_name = var.octopus_project_group_name
  space_id     = var.create_global_resources ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id
  take         = 1
}
moved {
  from = data.octopusdeploy_project_groups.all # <= v3.2.x
  to   = data.octopusdeploy_project_groups.default
}

data "octopusdeploy_space" "space" {
  count = var.create_global_resources ? 0 : 1
  name  = var.octopus_project_group_name
}
