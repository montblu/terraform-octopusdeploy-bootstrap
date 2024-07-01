resource "octopusdeploy_channel" "single-channel" {

  for_each = var.project_names

  name         = "${var.octopus_group_name} - single channel"
  project_id   = octopusdeploy_project.all[each.key].id
  lifecycle_id = octopusdeploy_lifecycle.from-stage-to-prod[0].id
  is_default   = false

}

resource "octopusdeploy_docker_container_registry" "DockerHub" {

  feed_uri    = "https://index.docker.io"
  name        = var.octopus_dockerhub_feed_name
  api_version = "v1"
}

resource "octopusdeploy_dynamic_worker_pool" "ubuntu" {

  name        = "${var.octopus_group_name}-workers-Ubuntu"
  space_id    = octopusdeploy_space.main.id
  worker_type = "Ubuntu2204"
  is_default  = true
}

resource "octopusdeploy_project" "all" {

  for_each = var.project_names

  space_id                             = octopusdeploy_space.main[0].id
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = octopusdeploy_lifecycle.from-stage-to-prod[0].id
  name                                 = each.key
  project_group_id                     = octopusdeploy_project_group.project_group[0].id
  tenanted_deployment_participation    = "Untenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  depends_on = [
    octopusdeploy_lifecycle.from-stage-to-prod,
    octopusdeploy_project_group.project_group
  ]
}


locals {
  octopusdeploy_environments = [for env in var.octopus_environments : data.octopusdeploy_environments.all[env].environments[0].id ]
}

resource "octopusdeploy_deployment_process" "all" {

  for_each = var.deployment
  project_id = octopusdeploy_project.all[each.key].id


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
        feed_id = octopusdeploy_docker_container_registry.DockerHub[0].id 
        image   = "octopusdeploy/worker-tools:${var.octopus_worker_tools_version}"
      }

      properties = {
        run_on_server                                   = true
        "Octopus.Action.Script.ScriptBody"              = <<-EOT
#!/bin/bash
set -e
bash -c ${var.k8s_set_image_deployment_command}

EOT
        "Octopus.Action.Script.Syntax"                  = "Bash"
        "Octopus.Action.KubernetesContainers.Namespace" = "#{Octopus.Action.Kubernetes.Namespace}"
      }
    }
  }

  dynamic "step" {
    for_each = var.cronjobs
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
          feed_id = octopusdeploy_docker_container_registry.DockerHub[0].id
          image   = "octopusdeploy/worker-tools:${var.octopus_worker_tools_version}"
        }

        properties = {
          run_on_server                                   = true
          "Octopus.Action.Script.ScriptBody"              = <<-EOT
#!/bin/bash
set -e
bash -c "kubectl version"
bash -c ${var.k8s_set_image_cronjob_command}

EOT
          "Octopus.Action.Script.Syntax"                  = "Bash"
          "Octopus.Action.KubernetesContainers.Namespace" = "#{Octopus.Action.Kubernetes.Namespace}"
        }
      }
    }
  }

  # Another workaround for this issue
  # https://github.com/OctopusDeployLabs/terraform-provider-octopusdeploy/issues/145
  step {
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

  step {
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
data "curl2" "slack_checkinstalled" {
  http_method = "GET"
  uri         = "${var.octopus_url}/api/communityactiontemplates/CommunityActionTemplates-370/actiontemplate"
  headers = {
    accept : "application/json"
    X-Octopus-ApiKey : var.octopus_api_key
    Content-Type : "application/json"
  }
}

data "curl2" "slack_install" {
  count       = data.curl2.slack_checkinstalled.response.status_code == 200 || var.newrelic_enabled == "true" ? 0 : 1
  http_method = "POST"
  uri         = "${var.octopus_url}/api/communityactiontemplates/CommunityActionTemplates-370/installation"
  headers = {
    accept : "application/json"
    X-Octopus-ApiKey : var.octopus_api_key
    Content-Type : "application/json"
  }
}

data "curl2" "slack_get_template_id" {
  http_method = "GET"
  uri         = "${var.octopus_url}/api/actiontemplates?partialName=Slack%20-%20Detailed%20Notification%20-%20Bash&take=1"
  headers = {
    accept : "application/json"
    X-Octopus-ApiKey : var.octopus_api_key
    Content-Type : "application/json"
  }
  depends_on = [data.curl2.slack_install]
}


#####
# Slack Notification Variables
#####

resource "octopusdeploy_variable" "slack_webhook" {
  for_each        = var.project_names
  name            = "HookUrl"
  type            = "Sensitive"
  is_sensitive    = true
  owner_id        = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  sensitive_value = var.slack_webhook
  scope {
    environments = [octopusdeploy_environment.main.id]
  }
}

resource "octopusdeploy_variable" "octopus_url" {
  for_each = var.project_names
  name     = "OctopusBaseUrl"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = var.octopus_url
  scope {
    environments = local.octopusdeploy_environments
    
  }
}

resource "octopusdeploy_variable" "slack_channel" {
  for_each = var.project_names
  name     = "Channel"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "DUMMY"
  scope {
    environments = local.octopusdeploy_environments
    
  }
}

resource "octopusdeploy_variable" "DeploymentInfoText" {
  for_each = var.project_names
  name     = "DeploymentInfoText"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "#{Octopus.Project.Name} release #{Octopus.Release.Number} to #{Octopus.Environment.Name} (#{Octopus.Machine.Name})"
  scope {
    environments = local.octopusdeploy_environments
  
  }
}

resource "octopusdeploy_variable" "IncludeFieldRelease" {
  for_each = var.project_names
  name     = "IncludeFieldRelease"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments
    
  }
}
resource "octopusdeploy_variable" "IncludeFieldMachine" {
  for_each = var.project_names
  name     = "IncludeFieldMachine"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments
    
  }
}

resource "octopusdeploy_variable" "IncludeFieldProject" {
  for_each = var.project_names
  name     = "IncludeFieldProject"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments
  
  }
}

resource "octopusdeploy_variable" "IncludeFieldEnvironment" {
  for_each = var.project_names
  name     = "IncludeFieldEnvironment"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments
    
  }
}

resource "octopusdeploy_variable" "IncludeFieldUsername" {
  for_each = var.project_names
  name     = "IncludeFieldUsername"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments

  }
}

resource "octopusdeploy_variable" "IncludeLinkOnFailure" {
  for_each = var.project_names
  name     = "IncludeLinkOnFailure"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments
    
  }
}

resource "octopusdeploy_variable" "IncludeErrorMessageOnFailure" {
  for_each = var.project_names
  name     = "IncludeErrorMessageOnFailure"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "True"
  scope {
    environments = local.octopusdeploy_environments
    
  }
}


##########
# New Relic
##########

resource "octopusdeploy_variable" "newrelic_apikey" {
  for_each     = var.project_names
  name         = "ApiKey"
  type         = "Sensitive"
  owner_id     = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  is_sensitive = true
  sensitive_value = var.newrelic_apikey
  scope {
    environments = local.octopusdeploy_environments
  
  }
}

resource "octopusdeploy_variable" "newrelic_guid" {
  for_each = var.project_names
  name     = "newrelic_guid"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = var.octopus_url
  scope {
    environments = [octopusdeploy_environment.main.id]
  }
}


resource "octopusdeploy_variable" "newrelic_user" {
  for_each = var.project_names
  name     = "User"
  type     = "String"
  owner_id = data.octopusdeploy_projects.all_services["${each.key}"].projects[0].id
  value    = "#{Octopus.Deployment.CreatedBy.Username}"
  scope {
    environments = local.octopusdeploy_environments
    

  }
}

