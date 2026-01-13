variable "octopus_project_group_name" {
  description = "Octopus resource name"
  type        = string
  default     = null
}

variable "octopus_environment" {
  description = "octopus_environment"
  type        = string
  default     = ""
}

variable "create_global_resources" {
  default = false
  type    = bool
}

variable "lifecycles" {
  type = list(object({
    name        = string
    description = optional(string, "Default description")
    release_retention_policy = optional(object({
      quantity_to_keep    = optional(number, 30)
      should_keep_forever = optional(bool, false)
      unit                = optional(string, "Days")
      }), {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Days"
      }
    )
    phases = optional(list(object({
      name                                  = string
      is_optional_phase                     = optional(bool, false)
      minimum_environments_before_promotion = optional(number, 1)
      optional_deployment_targets           = optional(list(string), [])
      automatic_deployment_targets          = optional(list(string), [])
    })), [])
  }))

  default = []
}

variable "octopus_github_feed_name" {
  description = "Octopus Github feed name"
  type        = string
  default     = "Github Container Registry"
}
variable "env_sort_order" {
  description = "Order of the environments"
  type        = list(string)
  default     = null
}