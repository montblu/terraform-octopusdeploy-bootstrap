variable "octopus_environments" {
  description = "octopus_environments"
  type        = list(string)
  default     = null
}

variable "project_names" {
  description = "Octopus project name list"
  type        = list(string)
  default     = null
}

variable "octopus_group_name" {
  description = "Octopus group name list"
  type        = string
  default     = null
}

variable "octopus_worker_tools_version" {
  description = "Octopus worker tools version"
  type        = string
  default     = null
}

variable "k8s_set_image_deployment_command" {
  description = "K8s set image command"
  type        = string
  #default     = "kubectl set image deployment/${each.key} ${each.key}=360379118495.dkr.ecr.us-east-1.amazonaws.com/ramp-${each.key}-stage-default:$(get_octopusvariable "Octopus.Release.Number") && kubectl rollout status deployment ${each.key}"
}

variable "k8s_set_image_cronjob_command" {
  description = "K8s set image command"
  type        = string
  #default     = "kubectl set image cronjob/${step.key} ${step.key}=360379118495.dkr.ecr.us-east-1.amazonaws.com/ramp-${each.key}-stage-default:$(get_octopusvariable "Octopus.Release.Number")"
}

variable "slack_webhook" {
  description = "slack webhook"
  type        = string
  default     = ""
}

variable "octopus_url" {
  description = "Octopus URL"
  type        = string
  default     = ""
}

variable "slack_channel" {
  description = "Slack channel"
  type        = string
  default     = ""
}

variable "newrelic_apikey" {
  description = "NewRelic APIKEY"
  type        = string
  default     = ""
}

variable "newrelic_guid" {
  description = "NewRelic GUID"
  type        = string
  default     = ""
}

variable "newrelic_user" {
  description = "NewRelic User"
  type        = string
}

variable "cronjobs" {
  description = "Cronjob list"
  type        = list(string)
}

variable "deployment" {
  description = "Deployment list"
  type        = list(string)
}

variable "octopus_dockerhub_feed_name" {
  description = "Octopus DockerHub feed name"
  type        = string
  default     = null
}

variable "newrelic_enabled" {
  description = "Enable newrelic api notification"
  type        = bool
  default     = false
}

variable "octopus_api_key" {
  description = "Octopus api key"
  type        = string
  default     = ""
}