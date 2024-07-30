#One env resource only
resource "octopusdeploy_docker_container_registry" "GitHub" {
  count       = var.octopus_dockerhub_feed_name == "" ? 0 : 1
  space_id    = var.octopus_space_id
  feed_uri    = "https://ghcr.io"
  name        = var.octopus_dockerhub_feed_name
  api_version = "v2"
}

#All envs resource
resource "octopusdeploy_kubernetes_cluster_deployment_target" "k8s" {
  name                = "${var.registry_prefix}-${var.environment}"
  environments        = [""]#[data.octopusdeploy_environments.current.environments[0].id]
  roles               = [""]#[data.octopusdeploy_environments.current.environments[0].id]
  cluster_certificate = octopusdeploy_certificate.k8s.id
  cluster_url         = var.k8s_cluster_url
  namespace           = var.k8s_namespace

  authentication {
    account_id = octopusdeploy_token_account.k8s.id
  }

  container {
    feed_id = octopusdeploy_docker_container_registry.GitHub[0].id
    image   = var.k8s_container_image
  }

  space_id          = var.octopus_space_id
  machine_policy_id = ""#data.octopusdeploy_machine_policies.default.machine_policies[0].id
                      

  depends_on = [
    octopusdeploy_certificate.k8s,
    octopusdeploy_token_account.k8s,
    data.octopusdeploy_machine_policies.default,
    data.octopusdeploy_environments.current
  ]
}
#All envs resource
resource "octopusdeploy_certificate" "k8s" {
  name             = "K8s Certificate - ${var.registry_prefix}-${var.environment}"
  certificate_data = var.k8s_certificate_data
  space_id         = var.octopus_space_id
  password         = var.k8s_certificate_password
  environments     = data.octopusdeploy_environments.all.environments[*].id
}
#All envs resource
resource "octopusdeploy_token_account" "k8s" {
  name         = "Token Account - ${var.registry_prefix}-${var.environment}"
  space_id     = var.octopus_space_id
  token        = var.k8s_account_token == "" ? kubernetes_secret.k8s_secrets[0].data["token"] : var.k8s_account_token
  environments = data.octopusdeploy_environments.all.environments[*].id

}
#All envs resource
resource "kubernetes_secret" "k8s_secrets" {
  count = var.k8s_account_token == "" ? 1 : 0
    metadata {
    name      = "octopus"
    namespace = "${var.registry_prefix}-${var.environment}"
  }
}