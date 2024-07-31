data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = var.create_space ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id

  depends_on = [
    octopusdeploy_environment.main
  ]

}

data "octopusdeploy_lifecycles" "all" {
  space_id = var.create_space ? octopusdeploy_space.main[0].id : data.octopusdeploy_space.space[0].id
  depends_on = [ octopusdeploy_lifecycle.lifecycles ]
}

data "octopusdeploy_project_groups" "all" {
  partial_name = var.octopus_project_group_name
}

data "octopusdeploy_space" "space" {
  count = var.create_space ? 0 : 1 
  name  = var.octopus_project_group_name
}