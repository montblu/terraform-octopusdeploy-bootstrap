output "octopus_space_id" {
  value       = octopusdeploy_space.main[0].id
  description = "The Octopus space name"
  sensitive   = false
}

output "octopus_lifecycle" {
  value       =  data.octopusdeploy_lifecycles.all.lifecycles[0].id
  description = "The Octopus lifecycle id"
  sensitive   = false
}

output "octopus_project_group_name" {
  value       = data.octopusdeploy_project_groups.all.partial_name
  description = "The Octopus project group."
  sensitive   = false
}

output "octopus_environments" {
  value       = data.octopusdeploy_environments.all.environments[*].name
  description = "The Octopus environments list."
  sensitive   = false
}

