data "octopusdeploy_environments" "all" {
  # We only want the environments created for this space_id so we avoid mixing things up
  space_id = octopusdeploy_space.main[0].id 
}

data "octopusdeploy_lifecycles" "all" {
  space_id = octopusdeploy_space.main[0].id
  depends_on = [ octopusdeploy_lifecycle.lifecycles ]
}

data "octopusdeploy_project_groups" "all" {
  partial_name = var.octopus_project_group_name
}