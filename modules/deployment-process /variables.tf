variable "octopus_environments" {
  description = "octopus_environments"
  type        = list()
  default     = null
}

variable "project_names" {
  description = "Octopus project name list"
  type        = list()
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
  default     = ""
}

variable "k8s_set_image_cronjob_command" {
  description = "K8s set image command"
  type        = string
  default     = ""
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
  default     = ""
}
