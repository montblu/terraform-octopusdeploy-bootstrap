variable "create_global_resources" {
  description = "The environment responsible for creating base global resources, i.e. deployment process"
  default     = false
  type        = bool
}

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

variable "octopus_organization_prefix" {
  description = "The organization prefix for the deployment process script to build the full ECR URL"
  type        = string
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

variable "ecr_url" {
  description = "K8s registry url"
  type        = string
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

variable "projects" {
  description = "Projects list"
  type        = map(any)
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

variable "octopus_github_feed_name" {
  description = "Octopus Github feed name"
  type        = string
  default     = "Github Container Registry"
}

variable "optional_steps" {
  default = {
    /*  
    optional_step1 = {
      name = "step1"
      script_body = "kubectl "
    },
    optional_step2 = {
      name = "step2"
      script_body = "kubectl "
    }   
   */
  }
}

variable "channels" {
  description = "Octopus channels to create per project"
  type = list(object({
    description  = optional(string, "")
    is_default   = optional(string, false)
    lifecycle_id = optional(string, "")
    name         = string
    project_id   = optional(string, "")
  }))
  default = [
    {
      name        = "main",
      description = "Default channel."
      is_default  = "true"
    }
  ]
}
