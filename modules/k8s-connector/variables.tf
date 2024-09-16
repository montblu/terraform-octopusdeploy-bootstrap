variable "octopus_environment" {
  description = "octopus_environment"
  type        = string
  default     = ""
}

variable "octopus_space_id" {
  description = "The Octopus space id"
  type        = string
  default     = ""
}

variable "octopus_project_group_name" {
  description = "Project Group name"
  type        = string
}

variable "k8s_container_image" {
  description = "K8s service prefix"
  type        = string
}

variable "k8s_certificate_data" {
  description = "K8s certificate data"
  type        = string
}

variable "k8s_certificate_password" {
  description = "K8s certificate password"
  type        = string
}

variable "k8s_account_token" {
  description = "K8s account token"
  type        = string
  default     = ""
}

variable "k8s_namespace" {
  description = "K8s account token"
  type        = string
}

variable "k8s_cluster_url" {
  description = "K8s account token"
  type        = string
}

variable "octopus_github_feed_name" {
  description = "Octopus Github feed name"
  type        = string
  default     = "Github Container Registry"
}

variable "create_global_resources" {
  default = false
  type    = bool
}
