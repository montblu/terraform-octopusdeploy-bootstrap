variable "octopus_group_name" {
  description = "Octopus resource name"
  type        = string
  default     = null
}

variable "project_names" {
  description = "Octopus project name list"
  type        = list()
  default     = null
}

variable "octopus_dockerhub_feed_name" {
  description = "Octopus DockerHub feed name"
  type        = list()
  default     = null
}

variable "octopus_environments" {
  description = "octopus_environments"
  type        = list()
  default     = null
}

