# One env resource only
resource "octopusdeploy_dynamic_worker_pool" "ubuntu" {
  count       = var.create_global_resources ? 1 : 0
  name        = "${var.octopus_project_group_name}-workers-Ubuntu"
  space_id    = var.octopus_space_id
  worker_type = "Ubuntu2204"
  is_default  = true
}

# All envs resource
resource "octopusdeploy_kubernetes_cluster_deployment_target" "k8s" {
  name                = "${var.octopus_project_group_name}-${var.octopus_environment}"
  environments        = [data.octopusdeploy_environments.current.environments[0].id]
  roles               = [data.octopusdeploy_environments.current.environments[0].name]
  cluster_certificate = octopusdeploy_certificate.k8s.id
  cluster_url         = var.k8s_cluster_url
  namespace           = var.k8s_namespace == "" ? "${var.octopus_project_group_name}-${var.octopus_environment}" : "${var.k8s_namespace}"

  authentication {
    account_id = octopusdeploy_token_account.k8s.id
  }

  container {
    feed_id = data.octopusdeploy_feeds.current.feeds[0].id
    image   = var.k8s_container_image
  }

  space_id          = var.octopus_space_id
  machine_policy_id = data.octopusdeploy_machine_policies.default.machine_policies[0].id

  default_worker_pool_id = local.data_worker_pool.id


  depends_on = [
    octopusdeploy_certificate.k8s,
    octopusdeploy_token_account.k8s,
    data.octopusdeploy_machine_policies.default,
    data.octopusdeploy_environments.current
  ]
}

# All envs resource
resource "octopusdeploy_certificate" "k8s" {
  name             = "K8s Certificate-${var.octopus_project_group_name}-${var.octopus_environment}"
  certificate_data = var.k8s_certificate_data
  space_id         = var.octopus_space_id
  password         = var.k8s_certificate_password
  environments     = [data.octopusdeploy_environments.current.environments[0].id]
}
# All envs resource
resource "octopusdeploy_token_account" "k8s" {
  name         = "Token Account-${var.octopus_project_group_name}-${var.octopus_environment}"
  space_id     = var.octopus_space_id
  token        = var.k8s_account_token == "" ? lookup(kubernetes_secret_v1.octopus[0].data, "token") : var.k8s_account_token
  environments = [data.octopusdeploy_environments.current.environments[0].id]

}
# All envs resource
resource "kubernetes_secret_v1" "octopus" {
  count                          = var.k8s_account_token == "" ? 1 : 0
  metadata {
    name      = kubernetes_service_account.octopus[0].metadata[0].name
    namespace = var.k8s_namespace == "" ? "${var.octopus_project_group_name}-${var.octopus_environment}" : "${var.k8s_namespace}"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.octopus[0].metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.octopus
  ]
}

resource "kubernetes_service_account" "octopus" {
  count                          = var.k8s_account_token == "" ? 1 : 0
  metadata {
    name      = "octopus"
    namespace =  var.k8s_namespace == "" ? "${var.octopus_project_group_name}-${var.octopus_environment}" : "${var.k8s_namespace}"
  }
}
resource "kubernetes_role" "octopus" {
  count                          = var.k8s_account_token == "" ? 1 : 0
  metadata {
    name      = "octopus"
    namespace = var.k8s_namespace == "" ? "${var.octopus_project_group_name}-${var.octopus_environment}" : "${var.k8s_namespace}"
  }

  rule {
    api_groups = [
      "",
      "apps",
      "extensions",
    ]
    resources = [
      "deployments",
      "pods",
      "replicasets",
    ]
    verbs = [
      "exec",
      "get",
      "list",
      "patch",
      "set",
      "watch",
    ]
  }
}

# bind cluster role to Octopus
resource "kubernetes_role_binding" "octopus" {
  count                          = var.k8s_account_token == "" ? 1 : 0
  metadata {
    name      = "octopus"
    namespace = var.k8s_namespace == "" ? "${var.octopus_project_group_name}-${var.octopus_environment}" : "${var.k8s_namespace}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.octopus[0].metadata[0].name
    namespace = var.k8s_namespace == "" ? "${var.octopus_project_group_name}-${var.octopus_environment}" : "${var.k8s_namespace}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.octopus[0].metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.octopus,
    kubernetes_role.octopus
  ]
}

resource "kubernetes_cluster_role" "octopus" {
   count       = var.create_global_resources ? 1 : 0
  metadata {
    name = "octopus"
  }

  rule {
    api_groups = [
      ""
    ]
    resources = [
      "namespaces"
    ]
    verbs = [
      "get",
      "list",
    ]
  }
}
