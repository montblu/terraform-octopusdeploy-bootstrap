## Breaking changes

### Upgrading to v6.x

Requires replacing the provider. Check the official documentation:
https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/guides/moving-from-octopus-deploy-labs-nam


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_octopusdeploy"></a> [octopusdeploy](#requirement\_octopusdeploy) | >=1.1.1, <2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_octopusdeploy"></a> [octopusdeploy](#provider\_octopusdeploy) | >=1.1.1, <2.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [octopusdeploy_docker_container_registry.github](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/docker_container_registry) | resource |
| [octopusdeploy_environment.main](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/environment) | resource |
| [octopusdeploy_lifecycle.main](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/lifecycle) | resource |
| [octopusdeploy_project_group.project_group](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/project_group) | resource |
| [octopusdeploy_space.main](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/space) | resource |
| [octopusdeploy_team.developers](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/team) | resource |
| [octopusdeploy_user_role.developers](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/user_role) | resource |
| [octopusdeploy_environments.all](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/environments) | data source |
| [octopusdeploy_project_groups.default](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/project_groups) | data source |
| [octopusdeploy_space.space](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/space) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_global_resources"></a> [create\_global\_resources](#input\_create\_global\_resources) | n/a | `bool` | `false` | no |
| <a name="input_lifecycles"></a> [lifecycles](#input\_lifecycles) | n/a | <pre>list(object({<br>    name        = string<br>    description = optional(string, "Default description")<br>    release_retention_policy = optional(object({<br>      quantity_to_keep    = optional(number, 30)<br>      should_keep_forever = optional(bool, false)<br>      unit                = optional(string, "Days")<br>      }), {<br>      quantity_to_keep    = 30<br>      should_keep_forever = false<br>      unit                = "Days"<br>      }<br>    )<br>    phases = optional(list(object({<br>      name                                  = string<br>      is_optional_phase                     = optional(bool, false)<br>      minimum_environments_before_promotion = optional(number, 1)<br>      optional_deployment_targets           = optional(list(string), [])<br>      automatic_deployment_targets          = optional(list(string), [])<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_octopus_environment"></a> [octopus\_environment](#input\_octopus\_environment) | octopus\_environment | `string` | `""` | no |
| <a name="input_octopus_github_feed_name"></a> [octopus\_github\_feed\_name](#input\_octopus\_github\_feed\_name) | Octopus Github feed name | `string` | `"Github Container Registry"` | no |
| <a name="input_octopus_project_group_name"></a> [octopus\_project\_group\_name](#input\_octopus\_project\_group\_name) | Octopus resource name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lifecycles"></a> [lifecycles](#output\_lifecycles) | The list of lifecycles created. |
| <a name="output_octopus_environment"></a> [octopus\_environment](#output\_octopus\_environment) | The Octopus environments list. |
| <a name="output_octopus_project_group_name"></a> [octopus\_project\_group\_name](#output\_octopus\_project\_group\_name) | The Octopus project group. |
| <a name="output_octopus_space_id"></a> [octopus\_space\_id](#output\_octopus\_space\_id) | The Octopus space name |
<!-- END_TF_DOCS -->
