variable "octopus_group_name" {
  description = "Octopus resource name"
  type        = string
  default     = null
}
variable "octopus_dockerhub_feed_name" {
  description = "Octopus DockerHub feed name"
  type        = string
  default     = null
}

variable "octopus_environments" {
  description = "octopus_environments"
  type        = list(string)
  default     = null
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
      is_optional_phase                     = optional(bool, null)
      minimum_environments_before_promotion = optional(number, 1)
      optional_deployment_targets           = optional(list(string), [])
    })), [])
  }))

  default = []
}
