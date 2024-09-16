## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_octopusdeploy"></a> [octopusdeploy](#requirement\_octopusdeploy) | 0.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_octopusdeploy"></a> [octopusdeploy](#provider\_octopusdeploy) | 0.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret.k8s_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [octopusdeploy_certificate.k8s](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/certificate) | resource |
| [octopusdeploy_docker_container_registry.GitHub](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/docker_container_registry) | resource |
| [octopusdeploy_kubernetes_cluster_deployment_target.k8s](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/kubernetes_cluster_deployment_target) | resource |
| [octopusdeploy_token_account.k8s](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/token_account) | resource |
| [octopusdeploy_environments.all](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/environments) | data source |
| [octopusdeploy_environments.current](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/environments) | data source |
| [octopusdeploy_feeds.current](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/feeds) | data source |
| [octopusdeploy_machine_policies.default](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/machine_policies) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_space"></a> [create\_space](#input\_create\_space) | n/a | `bool` | `false` | no |
| <a name="input_k8s_account_token"></a> [k8s\_account\_token](#input\_k8s\_account\_token) | K8s account token | `string` | `""` | no |
| <a name="input_k8s_certificate_data"></a> [k8s\_certificate\_data](#input\_k8s\_certificate\_data) | K8s certificate data | `string` | n/a | yes |
| <a name="input_k8s_certificate_password"></a> [k8s\_certificate\_password](#input\_k8s\_certificate\_password) | K8s certificate password | `string` | n/a | yes |
| <a name="input_k8s_cluster_url"></a> [k8s\_cluster\_url](#input\_k8s\_cluster\_url) | K8s account token | `string` | n/a | yes |
| <a name="input_k8s_container_image"></a> [k8s\_container\_image](#input\_k8s\_container\_image) | K8s service prefix | `string` | n/a | yes |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | K8s account token | `string` | n/a | yes |
| <a name="input_octopus_dockerhub_feed_name"></a> [octopus\_dockerhub\_feed\_name](#input\_octopus\_dockerhub\_feed\_name) | Octopus DockerHub feed name | `string` | `""` | no |
| <a name="input_octopus_environment"></a> [octopus\_environment](#input\_octopus\_environment) | octopus\_environment | `string` | `""` | no |
| <a name="input_octopus_space_id"></a> [octopus\_space\_id](#input\_octopus\_space\_id) | The Octopus space id | `string` | `""` | no |
| <a name="input_registry_prefix"></a> [registry\_prefix](#input\_registry\_prefix) | K8s service prefix | `string` | n/a | yes |

## Outputs

No outputs.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_octopusdeploy"></a> [octopusdeploy](#requirement\_octopusdeploy) | 0.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_octopusdeploy"></a> [octopusdeploy](#provider\_octopusdeploy) | 0.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret.k8s_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [octopusdeploy_certificate.k8s](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/certificate) | resource |
| [octopusdeploy_dynamic_worker_pool.ubuntu](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/dynamic_worker_pool) | resource |
| [octopusdeploy_kubernetes_cluster_deployment_target.k8s](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/kubernetes_cluster_deployment_target) | resource |
| [octopusdeploy_token_account.k8s](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/resources/token_account) | resource |
| [octopusdeploy_environments.all](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/environments) | data source |
| [octopusdeploy_environments.current](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/environments) | data source |
| [octopusdeploy_feeds.current](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/feeds) | data source |
| [octopusdeploy_machine_policies.default](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/machine_policies) | data source |
| [octopusdeploy_worker_pools.all](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/0.22.0/docs/data-sources/worker_pools) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_global_resources"></a> [create\_global\_resources](#input\_create\_global\_resources) | n/a | `bool` | `false` | no |
| <a name="input_k8s_account_token"></a> [k8s\_account\_token](#input\_k8s\_account\_token) | K8s account token | `string` | `""` | no |
| <a name="input_k8s_certificate_data"></a> [k8s\_certificate\_data](#input\_k8s\_certificate\_data) | K8s certificate data | `string` | n/a | yes |
| <a name="input_k8s_certificate_password"></a> [k8s\_certificate\_password](#input\_k8s\_certificate\_password) | K8s certificate password | `string` | n/a | yes |
| <a name="input_k8s_cluster_url"></a> [k8s\_cluster\_url](#input\_k8s\_cluster\_url) | K8s account token | `string` | n/a | yes |
| <a name="input_k8s_container_image"></a> [k8s\_container\_image](#input\_k8s\_container\_image) | K8s service prefix | `string` | n/a | yes |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | K8s account token | `string` | n/a | yes |
| <a name="input_octopus_environment"></a> [octopus\_environment](#input\_octopus\_environment) | octopus\_environment | `string` | `""` | no |
| <a name="input_octopus_github_feed_name"></a> [octopus\_github\_feed\_name](#input\_octopus\_github\_feed\_name) | Octopus Github feed name | `string` | `"Github Container Registry"` | no |
| <a name="input_octopus_project_group_name"></a> [octopus\_project\_group\_name](#input\_octopus\_project\_group\_name) | Project Group name | `string` | n/a | yes |
| <a name="input_octopus_space_id"></a> [octopus\_space\_id](#input\_octopus\_space\_id) | The Octopus space id | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->