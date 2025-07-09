locals {
  channels = merge([
    for project_key, _ in var.projects : {
      for channel in var.channels : "${project_key} ${channel.name}" => merge(tomap(channel), { project_name = project_key })
    }
  ]...)
}

# One env resource only
resource "octopusdeploy_channel" "main" {
  for_each = var.create_global_resources ? local.channels : {}

  name         = each.value.name
  space_id     = var.octopus_space_id
  project_id   = each.value.project_id == "" ? octopusdeploy_project.all[each.value.project_name].id : each.value.project_id
  lifecycle_id = each.value.lifecycle_id == "" ? var.octopus_lifecycle_id : each.value.lifecycle_id
  is_default   = each.value.is_default

  depends_on = [octopusdeploy_process.all]
}


# One env resource only
resource "octopusdeploy_project" "all" {
  for_each = var.create_global_resources ? var.projects : {}

  space_id                             = var.octopus_space_id
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = var.octopus_lifecycle_id
  name                                 = each.key
  project_group_id                     = data.octopusdeploy_project_groups.default.project_groups[0].id
  tenanted_deployment_participation    = "Untenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  depends_on = [
  ]
}

resource "octopusdeploy_process" "all" {
  for_each = var.create_global_resources ? var.projects : {}

  space_id   = var.octopus_space_id
  project_id = local.data_all_projects[each.key].id
}

resource "octopusdeploy_process_steps_order" "steps_order" {
  for_each   = var.create_global_resources ? var.projects : {}
  space_id   = var.octopus_space_id
  process_id = octopusdeploy_process.all[each.key].id
  steps = compact([
    try(octopusdeploy_process_step.set_image[each.key].id, null),
    try(octopusdeploy_process_step.cronjobs[each.key].id, null),
    try(octopusdeploy_process_step.optional_step[each.key].id, null),
    try(octopusdeploy_process_step.global_optional_step[each.key].id, null),
    try(octopusdeploy_process_templated_step.slack_notification_step[each.key].id, null),
    try(octopusdeploy_process_step.newrelic_step[each.key].id, null),
  ])
}
resource "octopusdeploy_process_step" "set_image" {
  for_each = var.create_global_resources ? var.projects : {}

  process_id          = octopusdeploy_process.all[each.key].id
  space_id            = var.octopus_space_id
  name                = "Set image - ${each.key}"
  condition           = "Success"
  package_requirement = "LetOctopusDecide"
  start_trigger       = "StartAfterPrevious"

  type           = "Octopus.Script"
  is_required    = true
  worker_pool_id = local.data_worker_pool.id
  execution_properties = {
    "Octopus.Action.EnabledFeatures"           = "Octopus.Features.SubstituteInFiles"
    "Octopus.Action.RunOnServer"               = "true"
    "Octopus.Action.Script.ScriptSource"       = "Inline"
    "Octopus.Action.Script.ScriptBody"         = local.set_image_script_body
    "Octopus.Action.Script.Syntax"             = "Bash"
    "Octopus.Action.SubstituteInFiles.Enabled" = "True"
    "OctopusUseBundledTooling"                 = "False"
  }
  properties = {
    "Octopus.Action.TargetRoles" = join(",", var.octopus_environments)
  }

  container = {
    feed_id = data.octopusdeploy_feeds.current.feeds[0].id
    image   = "montblu/workertools:${var.octopus_worker_tools_version}"
  }
}

resource "octopusdeploy_process_step" "cronjobs" {
  for_each = {
    for pair in flatten([
      for project_key, project in var.projects : [
        for id, cronjob in project.cronjobs : {
          key        = "${project_key}.${id}"
          project_key = project_key
          cronjob     = cronjob
        }
      ]
    ]) : pair.key => {
      project_key = pair.project_key
      cronjob     = pair.cronjob
    }
  }

  process_id          = octopusdeploy_process.all[each.value.project_key].id
  space_id            = var.octopus_space_id
  name                = "Set cron image - ${each.value.project_key} - ${each.value.cronjob}"
  condition           = "Success"
  package_requirement = "LetOctopusDecide"
  start_trigger       = "StartAfterPrevious"

  type           = "Octopus.Script"
  is_required    = true
  worker_pool_id = local.data_worker_pool.id
  execution_properties = {
    "Octopus.Action.EnabledFeatures"           = "Octopus.Features.SubstituteInFiles"
    "Octopus.Action.RunOnServer"               = "true"
    "Octopus.Action.Script.ScriptSource"       = "Inline"
    "Octopus.Action.Script.ScriptBody"         = local.cronjobs_script_body
    "Octopus.Action.Script.Syntax"             = "Bash"
    "Octopus.Action.SubstituteInFiles.Enabled" = "True"
    "OctopusUseBundledTooling"                 = "False"
  }
  properties = {
    "Octopus.Action.TargetRoles" = join(",", var.octopus_environments)
  }

  container = {
    feed_id = data.octopusdeploy_feeds.current.feeds[0].id
    image   = "montblu/workertools:${var.octopus_worker_tools_version}"
  }
}

resource "octopusdeploy_process_step" "optional_step" {
  for_each = var.create_global_resources ? var.optional_steps : {}

  process_id          = octopusdeploy_process.all[each.key].id
  space_id            = var.octopus_space_id
  name                = "optional step - ${each.key}"
  condition           = "Success"
  package_requirement = "LetOctopusDecide"
  start_trigger       = "StartAfterPrevious"

  type           = "Octopus.Script"
  is_required    = true
  worker_pool_id = local.data_worker_pool.id
  execution_properties = {
    "Octopus.Action.EnabledFeatures"           = "Octopus.Features.SubstituteInFiles"
    "Octopus.Action.RunOnServer"               = "true"
    "Octopus.Action.Script.ScriptSource"       = "Inline"
    "Octopus.Action.Script.ScriptBody"         = lookup(each.value, "script_body", "")
    "Octopus.Action.Script.Syntax"             = "Bash"
    "Octopus.Action.SubstituteInFiles.Enabled" = "True"
    "OctopusUseBundledTooling"                 = "False"
  }
  properties = {
    "Octopus.Action.TargetRoles" = join(",", var.octopus_environments)
  }

  container = {
    feed_id = data.octopusdeploy_feeds.current.feeds[0].id
    image   = "montblu/workertools:${var.octopus_worker_tools_version}"
  }
}

resource "octopusdeploy_process_step" "global_optional_step" {
  for_each = var.create_global_resources && length(var.optional_steps) > 0 ? var.projects : {}

  process_id          = octopusdeploy_process.all[each.key].id
  space_id            = var.octopus_space_id
  name                = "global project optional step - ${each.key}"
  condition           = "Success"
  package_requirement = "LetOctopusDecide"
  start_trigger       = "StartAfterPrevious"


  type           = "Octopus.Script"
  is_required    = lookup(var.optional_steps, "is_required", true)
  worker_pool_id = local.data_worker_pool.id

  properties = lookup(var.optional_steps, "properties", {})
  container = {
    feed_id = data.octopusdeploy_feeds.current.feeds[0].id
    image   = "montblu/workertools:${var.octopus_worker_tools_version}"
  }
}

resource "octopusdeploy_process_templated_step" "slack_notification_step" {
  for_each         = var.create_global_resources ? (var.enable_newrelic ? var.projects : {}) : {}
  process_id       = octopusdeploy_process.all[each.key].id
  space_id         = var.octopus_space_id
  name             = "Slack Notification Step - ${each.key}"
  start_trigger    = "StartAfterPrevious"
  template_id      = jsondecode(data.curl2.slack_get_template_id.response.body).Items[0].Id
  template_version = 4

  properties = {
    "Octopus.Action.TargetRoles" = join(",", var.octopus_environments)
  }

  execution_properties = {
    "Octopus.Action.RunOnServer"       = "True",
    "My.Custom.Property"               = "Something",
    "Octopus.Action.Script.Syntax"     = "Bash"
    "Octopus.Action.Script.ScriptBody" = lookup(jsondecode(data.curl2.slack_get_template_id.response.body).Items[0].Properties, "Octopus.Action.Script.ScriptBody")
  }
}

resource "octopusdeploy_process_step" "newrelic_step" {
  for_each = var.create_global_resources ? (var.enable_newrelic ? var.projects : {}) : {}

  process_id          = octopusdeploy_process.all[each.key].id
  space_id            = var.octopus_space_id
  name                = "NewRelic - ${each.key}"
  condition           = "Success"
  package_requirement = "LetOctopusDecide"
  start_trigger       = "StartAfterPrevious"

  type           = "Octopus.Script"
  is_required    = true
  worker_pool_id = local.data_worker_pool.id
  execution_properties = {
    "Octopus.Action.EnabledFeatures"           = "Octopus.Features.SubstituteInFiles"
    "Octopus.Action.RunOnServer"               = "true"
    "Octopus.Action.Script.ScriptSource"       = "Inline"
    "Octopus.Action.Script.Syntax"             = "Bash"
    "Octopus.Action.SubstituteInFiles.Enabled" = "True"
    "OctopusUseBundledTooling"                 = "False"
    "Octopus.Action.Script.ScriptBody"         = <<-EOT
USER="$(get_octopusvariable "Octopus.Deployment.CreatedBy.Username")"
RELEASE="$(get_octopusvariable "Octopus.Release.Number")"
NOTES="$(get_octopusvariable "Octopus.Release.Notes")"
GUID="$(get_octopusvariable "newrelic_guid")"
apikey()
{
cat <<EOF
$(get_octopusvariable "ApiKey")
EOF
}
generate_post_data()
{
  cat <<EOF
{
  "query":"mutation { changeTrackingCreateDeployment(    deployment: { version: \"$RELEASE\", entityGuid: \"$GUID\" }  ) {    deploymentId    entityGuid  }}",
  "variables":""
}
EOF
}
curl ${var.newrelic_api_url} \
  -H 'Content-Type: application/json' \
  -H "API-Key: $(apikey)" \
  --data-binary "$(generate_post_data)" \
  -s
EOT
  }
  properties = {
    "Octopus.Action.TargetRoles" = join(",", var.octopus_environments)
  }

  container = {
    feed_id = data.octopusdeploy_feeds.current.feeds[0].id
    image   = "montblu/workertools:${var.octopus_worker_tools_version}"
  }
}

#####
# ECR Variables
#####
resource "octopusdeploy_variable" "ecr_url" {
  for_each = var.projects

  space_id = var.octopus_space_id
  name     = "ecr_url"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = var.ecr_url
  scope {
    environments = [data.octopusdeploy_environments.current.environments[0].id]
  }

  depends_on = [
    octopusdeploy_project.all
  ]
}

resource "octopusdeploy_variable" "deployment_name" {
  for_each = var.projects

  space_id = var.octopus_space_id
  name     = "deployment_name"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = coalesce(each.value.deployment_name, "${var.octopus_organization_prefix}-${var.environment}-${each.key}")
  scope {
    environments = [data.octopusdeploy_environments.current.environments[0].id]
  }

  depends_on = [
    octopusdeploy_project.all
  ]

}
###############
# Slack Template Installation
###############
/*
data "curl2" "slack_checkinstalled" {
  http_method = "GET"
  uri         = "${var.octopus_address}/api/communityactiontemplates/CommunityActionTemplates-370/actiontemplate"
  headers = {
    accept : "application/json"
    X-Octopus-ApiKey : var.octopus_api_key
    Content-Type : "application/json"
  }
}

data "curl2" "slack_install" {
  count       = data.curl2.slack_checkinstalled.response.status_code == 200 ? 0 : 1
  http_method = "POST"
  uri         = "${var.octopus_address}/api/communityactiontemplates/CommunityActionTemplates-370/installation"
  headers = {
    accept : "application/json"
    X-Octopus-ApiKey : var.octopus_api_key
    Content-Type : "application/json"
  }
}
*/

data "curl2" "slack_get_template_id" {
  http_method = "GET"
  uri         = "${var.octopus_address}/api/${var.octopus_space_id}/actiontemplates?skip=0&take=1&partialName=Slack%20-%20Detailed%20Notification%20-%20Bash"
  headers = {
    accept : "application/json"
    X-Octopus-ApiKey : var.octopus_api_key
    Content-Type : "application/json"
  }
}


#####
# Slack Notification Variables
#####
resource "octopusdeploy_variable" "slack_webhook" {
  for_each        = var.enable_slack ? var.projects : {}
  space_id        = var.octopus_space_id
  name            = "HookUrl"
  type            = "Sensitive"
  is_sensitive    = true
  owner_id        = local.data_all_projects[each.key].id
  sensitive_value = var.slack_webhook
  scope {
    environments = [data.octopusdeploy_environments.current.environments[0].id]
  }
}

resource "octopusdeploy_variable" "octopus_url" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "OctopusBaseUrl"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = var.octopus_address
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "slack_channel" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "Channel"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = var.slack_channel
  scope {
    environments = [data.octopusdeploy_environments.current.environments[0].id]

  }
}

resource "octopusdeploy_variable" "DeploymentInfoText" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "DeploymentInfoText"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "#{Octopus.Project.Name} release #{Octopus.Release.Number} to #{Octopus.Environment.Name} (#{Octopus.Machine.Name})"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "IncludeFieldRelease" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeFieldRelease"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}
resource "octopusdeploy_variable" "IncludeFieldMachine" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeFieldMachine"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "IncludeFieldProject" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeFieldProject"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "IncludeFieldEnvironment" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeFieldEnvironment"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "IncludeFieldUsername" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeFieldUsername"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "IncludeLinkOnFailure" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeLinkOnFailure"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "IncludeErrorMessageOnFailure" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "IncludeErrorMessageOnFailure"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "True"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}


##########
# New Relic
##########

resource "octopusdeploy_variable" "newrelic_apikey" {
  for_each        = var.enable_newrelic ? var.projects : {}
  space_id        = var.octopus_space_id
  name            = "ApiKey"
  type            = "Sensitive"
  owner_id        = local.data_all_projects[each.key].id
  is_sensitive    = true
  sensitive_value = var.newrelic_apikey
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "newrelic_guid" {
  for_each = var.enable_newrelic ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "newrelic_guid"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = var.newrelic_guid_map[each.key]
  scope {
    environments = [data.octopusdeploy_environments.current.environments[0].id]
  }
}


resource "octopusdeploy_variable" "newrelic_user" {
  for_each = var.enable_newrelic ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "User"
  type     = "String"
  owner_id = local.data_all_projects[each.key].id
  value    = "#{Octopus.Deployment.CreatedBy.Username}"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id
  }
}
