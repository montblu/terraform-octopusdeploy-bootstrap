output "octopus_space_id" {
  value       = try(octopusdeploy_space.main[0].id, "")
  description = "The Octopus space name"
  sensitive   = false
}

output "octopus_project_group_name" {
  value       = try(data.octopusdeploy_project_groups.default.partial_name, "")
  description = "The Octopus project group."
  sensitive   = false
}

output "octopus_environment" {
  value       = try(local.envs, "")
  description = "The Octopus environments list."
  sensitive   = false
}

output "lifecycles" {
  value       = octopusdeploy_lifecycle.main
  description = "The list of lifecycles created."
}

