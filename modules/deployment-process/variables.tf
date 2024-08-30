variable "octopus_environments" {
  description = "The Octopus Environements"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "octopus_environments"
  type        = string
  default     = ""
}

variable "octopus_lifecycle_id" {
  description = "The Octopus lifecycle id"
  type        = string
  default     = ""
}

variable "octopus_project_group_name" {
  description = "The Octopus Project group name"
  type        = string
  default     = ""
}

variable "octopus_space_id" {
  description = "The Octopus space id"
  type        = string
  default     = ""
}

variable "octopus_worker_tools_version" {
  description = "Octopus worker tools version"
  type        = string
  default     = "6.1-ubuntu.22.04"
}

variable "k8s_registry_url" {
  description = "K8s registry url"
  type        = string
}

variable "registry_prefix" {
  description = "K8s service prefix"
  type        = string
  default     = ""
}

variable "registry_sufix" {
  type    = string
  default = ""
}

variable "octopus_address" {
  description = "Octopus URL"
  type        = string
}

variable "enable_slack" {
  description = "Enable slack API notification"
  type        = bool
}

variable "slack_webhook" {
  description = "slack webhook"
  type        = string
  default     = ""
}

variable "slack_channel" {
  description = "Slack channel"
  type        = string
  default     = ""
}

variable "deployment_projects" {
  description = "Deployment list"
}

variable "enable_newrelic" {
  description = "Enable newrelic API notification"
  type        = bool
}

variable "newrelic_user" {
  description = "NewRelic User"
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

variable "octopus_api_key" {
  description = "Octopus api key"
  type        = string
  default     = ""
}

variable "octopus_dockerhub_feed_name" {
  description = "Octopus DockerHub feed name"
  type        = string
  default     = ""
}

variable "optional_steps" {
  default     = { 
    optional_step1 = {
      name = "step1"
      script_body = "kubectl "
    },
    optional_step2 = {
      name = "step2"
      script_body = "kubectl "
    }
 }
}
