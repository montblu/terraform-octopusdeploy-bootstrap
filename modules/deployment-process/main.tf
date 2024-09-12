locals {
  channels = flatten([
    for project_key, project_value in var.projects : [
      for channel in var.channels : {
        description  = channel["description"]
        is_default   = channel["is_default"]
        lifecycle_id = channel["lifecycle_id"] == "" ? var.octopus_lifecycle_id : channel["lifecycle_id"]
        name         = channel["name"]
        project_id   = channel["project_id"] == "" ? octopusdeploy_project.all[project_key].id : channel["project_id"]
        project_name = project_key
      }
    ]
  ])
}

#One env resource only
resource "octopusdeploy_channel" "main" {
  for_each = { for channel in local.channels : "${channel.project_name} ${channel.name}" => channel }

  name         = each.value.name
  space_id     = var.octopus_space_id
  project_id   = each.value.project_id
  lifecycle_id = each.value.lifecycle_id
  is_default   = each.value.is_default

  depends_on = [octopusdeploy_deployment_process.all]
}

resource "octopusdeploy_dynamic_worker_pool" "ubuntu" {
  count       = var.octopus_space_id == "" ? 0 : 1
  name        = "${var.octopus_project_group_name}-workers-Ubuntu"
  space_id    = var.octopus_space_id
  worker_type = "Ubuntu2204"
  is_default  = true
}

#One env resource only
resource "octopusdeploy_project" "all" {
  for_each = var.projects

  space_id                             = var.octopus_space_id
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = var.octopus_lifecycle_id
  name                                 = each.key
  project_group_id                     = data.octopusdeploy_project_groups.all.project_groups[0].id
  tenanted_deployment_participation    = "Untenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  depends_on = [
  ]
}


locals {
  octopusdeploy_environments = var.octopus_environments
}
#One env resource only
resource "octopusdeploy_deployment_process" "all" {
  for_each = var.projects

  space_id   = var.octopus_space_id
  project_id = octopusdeploy_project.all[each.key].id
  depends_on = [octopusdeploy_project.all]

  # to update steps, and actions, we need to delete ALL STEPS first (via web console)
  # https://github.com/OctopusDeployLabs/terraform-provider-octopusdeploy/issues/276

  step {
    condition           = "Success"
    name                = "Set image on for ${each.key}"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    target_roles        = var.octopus_environments

    run_kubectl_script_action {
      name           = "Set image for ${each.key}"
      is_required    = true
      worker_pool_id = octopusdeploy_dynamic_worker_pool.ubuntu[0].id

      container {
        feed_id = data.octopusdeploy_feeds.current.feeds[0].id
        image   = "montblu/workertools:${var.octopus_worker_tools_version}"
      }

      properties = {
        run_on_server                                   = true
        "Octopus.Action.Script.ScriptBody"              = <<-EOT
#!/bin/bash
set -e
bash -c "kubectl set image deployment/${each.key} ${each.key}=${var.k8s_registry_url}/${var.registry_prefix}${var.registry_prefix != "" ? "-" : ""}${each.key}${var.registry_sufix != "" ? "-" : ""}${var.registry_sufix}:$(get_octopusvariable "Octopus.Release.Number") && kubectl rollout status deployment ${each.key}"

EOT
        "Octopus.Action.Script.Syntax"                  = "Bash"
        "Octopus.Action.KubernetesContainers.Namespace" = "#{Octopus.Action.Kubernetes.Namespace}"
      }
    }
  }

  dynamic "step" {
    for_each = toset(lookup(each.value, "cronjobs", []))
    content {
      condition           = "Success"
      name                = "Set image for ${step.key}"
      package_requirement = "LetOctopusDecide"
      start_trigger       = "StartAfterPrevious"
      target_roles        = var.octopus_environments

      run_kubectl_script_action {
        name           = "Set image for ${step.key}"
        is_required    = true
        worker_pool_id = octopusdeploy_dynamic_worker_pool.ubuntu[0].id

        container {
          feed_id = data.octopusdeploy_feeds.current.feeds[0].id
          image   = "montblu/workertools:${var.octopus_worker_tools_version}"
        }

        properties = {
          run_on_server                                   = true
          "Octopus.Action.Script.ScriptBody"              = <<-EOT
#!/bin/bash
set -e
bash -c "kubectl version"
bash -c "kubectl set image cronjob/${step.key} ${step.key}=${var.k8s_registry_url}/${var.registry_prefix}-${each.key}-${var.registry_sufix}:$(get_octopusvariable "Octopus.Release.Number")"

EOT
          "Octopus.Action.Script.Syntax"                  = "Bash"
          "Octopus.Action.KubernetesContainers.Namespace" = "#{Octopus.Action.Kubernetes.Namespace}"
        }
      }
    }
  }

  # Another workaround for this issue
  # https://github.com/OctopusDeployLabs/terraform-provider-octopusdeploy/issues/145
  dynamic "step" {
    for_each = var.enable_slack == true ? var.projects : {}
    content {
      condition           = "Always"
      name                = "Slack Detailed Notification for ${each.key}"
      package_requirement = "LetOctopusDecide"
      start_trigger       = "StartAfterPrevious"
      target_roles        = var.octopus_environments
      run_script_action {
        name = "Slack Template Notification"
        action_template {
          # This id can be found on the community template URL on octopus app
          # https://filingramp.octopus.app/app#/Spaces-1/library/steptemplates/community/CommunityActionTemplates-370
          community_action_template_id = "CommunityActionTemplates-370"
          version                      = 4
          id                           = jsondecode(data.curl2.slack_get_template_id.response.body).Items[0].Id

        }
        script_syntax = "Bash"
        script_body   = lookup(jsondecode(data.curl2.slack_get_template_id.response.body).Items[0].Properties, "Octopus.Action.Script.ScriptBody")
      }
    }
  }

  dynamic "step" {
    for_each = var.enable_newrelic == true ? var.projects : {}
    content {
      condition           = "Success"
      name                = "New Relic Deployment for ${each.key}"
      package_requirement = "LetOctopusDecide"
      start_trigger       = "StartAfterPrevious"
      run_script_action {
        name           = "New Relic Deployment for ${each.key}"
        is_required    = true
        worker_pool_id = octopusdeploy_dynamic_worker_pool.ubuntu[0].id
        run_on_server  = "true"
        script_body    = <<-EOT
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
curl https://api.newrelic.com/graphql \
  -H 'Content-Type: application/json' \
  -H "API-Key: $(apikey)" \
  --data-binary "$(generate_post_data)" \
  -s
EOT
        script_syntax  = "Bash"
        script_source  = "Inline"
      }
    }
  }

  dynamic "step" {
    for_each = var.optional_steps
    content {
      condition           = "Success"
      name                = "${lookup(step.value, "name", "")} - ${each.key}"
      package_requirement = "LetOctopusDecide"
      start_trigger       = "StartAfterPrevious"
      target_roles        = var.octopus_environments

      run_kubectl_script_action {
        name           = "Optional Step for ${lookup(step.value, "name", "")} - ${each.key}"
        is_required    = true
        worker_pool_id = octopusdeploy_dynamic_worker_pool.ubuntu[0].id

        container {
          feed_id = data.octopusdeploy_feeds.current.feeds[0].id
          image   = "montblu/workertools:${var.octopus_worker_tools_version}"
        }

        properties = {
          run_on_server                                   = true
          "Octopus.Action.Script.ScriptBody"              = lookup(step.value, "script_body", "")
          "Octopus.Action.Script.Syntax"                  = "Bash"
          "Octopus.Action.KubernetesContainers.Namespace" = "#{Octopus.Action.Kubernetes.Namespace}"
        }
      }
    }
  }

  # Ugly workaround for an ugly provider
  lifecycle {
    ignore_changes = [
      step[0].run_kubectl_script_action,
      step[0].properties,
      step[1].run_kubectl_script_action,
      step[1].properties,
      step[2].run_kubectl_script_action,
      step[2].properties,
      step[3].run_kubectl_script_action,
      step[3].properties,
      step[0].run_script_action,
      step[1].run_script_action,
      step[2].run_script_action,
      step[3].run_script_action,
      step[4].run_script_action
    ]
  }
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
  uri         = "${var.octopus_address}/api/actiontemplates?partialName=Slack%20-%20Detailed%20Notification%20-%20Bash&take=1"
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
  owner_id        = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
  value    = "DUMMY"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id

  }
}

resource "octopusdeploy_variable" "DeploymentInfoText" {
  for_each = var.enable_slack ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "DeploymentInfoText"
  type     = "String"
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
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
  owner_id        = octopusdeploy_project.all["${each.key}"].id
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
  owner_id = octopusdeploy_project.all["${each.key}"].id
  value    = var.octopus_address
  scope {
    environments = [data.octopusdeploy_environments.current.environments[0].id]
  }
}


resource "octopusdeploy_variable" "newrelic_user" {
  for_each = var.enable_newrelic ? var.projects : {}
  space_id = var.octopus_space_id
  name     = "User"
  type     = "String"
  owner_id = octopusdeploy_project.all["${each.key}"].id
  value    = "#{Octopus.Deployment.CreatedBy.Username}"
  scope {
    environments = data.octopusdeploy_environments.all.environments[*].id
  }
}
