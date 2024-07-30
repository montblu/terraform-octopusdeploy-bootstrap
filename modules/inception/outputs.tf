output "octopus_space_id" {
  value       = try(octopusdeploy_space.main[0].id, "")
  description = "The Octopus space name"
  sensitive   = false
}

output "octopus_lifecycle" {
  value       = try(octopusdeploy_lifecycle.lifecycles["${var.lifecycles[0].name}"].id, "")
  description = "The Octopus lifecycle id"
  sensitive   = false
  depends_on = [ octopusdeploy_lifecycle.lifecycles ]
}

output "octopus_project_group_name" {
  value       = try(data.octopusdeploy_project_groups.all.partial_name, "")
  description = "The Octopus project group."
  sensitive   = false
}

output "octopus_environments" {
  value       = try(data.octopusdeploy_environments.all.environments[*].name, "")
  description = "The Octopus environments list."
  sensitive   = false
}

