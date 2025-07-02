<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_curl2"></a> [curl2](#requirement\_curl2) | 1.7.2 |
| <a name="requirement_octopusdeploy"></a> [octopusdeploy](#requirement\_octopusdeploy) | >=1.1.1, <2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_curl2"></a> [curl2](#provider\_curl2) | 1.7.2 |
| <a name="provider_octopusdeploy"></a> [octopusdeploy](#provider\_octopusdeploy) | >=1.1.1, <2.0.0 |

### >= v6.0.0

#### Required to replace provider:
https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/guides/moving-from-octopus-deploy-labs-nam

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [octopusdeploy_channel.main](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/channel) | resource |
| [octopusdeploy_deployment_process.all](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/deployment_process) | resource |
| [octopusdeploy_project.all](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/project) | resource |
| [octopusdeploy_variable.DeploymentInfoText](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeErrorMessageOnFailure](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeFieldEnvironment](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeFieldMachine](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeFieldProject](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeFieldRelease](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeFieldUsername](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.IncludeLinkOnFailure](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.deployment_name](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.ecr_url](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.newrelic_apikey](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.newrelic_guid](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.newrelic_user](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.octopus_url](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.slack_channel](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [octopusdeploy_variable.slack_webhook](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/resources/variable) | resource |
| [curl2_curl2.slack_get_template_id](https://registry.terraform.io/providers/DanielKoehler/curl2/1.7.2/docs/data-sources/curl2) | data source |
| [octopusdeploy_environments.all](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/environments) | data source |
| [octopusdeploy_environments.current](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/environments) | data source |
| [octopusdeploy_feeds.current](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/feeds) | data source |
| [octopusdeploy_machine_policies.default](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/machine_policies) | data source |
| [octopusdeploy_project_groups.default](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/project_groups) | data source |
| [octopusdeploy_projects.all](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/projects) | data source |
| [octopusdeploy_worker_pools.all](https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/data-sources/worker_pools) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_channels"></a> [channels](#input\_channels) | Octopus channels to create per project | <pre>list(object({<br>    description  = optional(string, "")<br>    is_default   = optional(string, false)<br>    lifecycle_id = optional(string, "")<br>    name         = string<br>    project_id   = optional(string, "")<br>  }))</pre> | <pre>[<br>  {<br>    "description": "Default channel.",<br>    "is_default": "true",<br>    "name": "main"<br>  }<br>]</pre> | no |
| <a name="input_create_global_resources"></a> [create\_global\_resources](#input\_create\_global\_resources) | The environment responsible for creating base global resources, i.e. deployment process | `bool` | `false` | no |
| <a name="input_ecr_url"></a> [ecr\_url](#input\_ecr\_url) | K8s registry url | `string` | n/a | yes |
| <a name="input_enable_newrelic"></a> [enable\_newrelic](#input\_enable\_newrelic) | Enable newrelic API notification | `bool` | n/a | yes |
| <a name="input_enable_slack"></a> [enable\_slack](#input\_enable\_slack) | Enable slack API notification | `bool` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | octopus\_environments | `string` | `""` | no |
| <a name="input_newrelic_api_url"></a> [newrelic\_api\_url](#input\_newrelic\_api\_url) | n/a | `string` | `"https://api.newrelic.com/graphql"` | no |
| <a name="input_newrelic_apikey"></a> [newrelic\_apikey](#input\_newrelic\_apikey) | NewRelic APIKEY | `string` | `""` | no |
| <a name="input_newrelic_guid_map"></a> [newrelic\_guid\_map](#input\_newrelic\_guid\_map) | NewRelic GUID map with values per project | `map(string)` | `{}` | no |
| <a name="input_newrelic_resource_name_prefix"></a> [newrelic\_resource\_name\_prefix](#input\_newrelic\_resource\_name\_prefix) | n/a | `string` | `""` | no |
| <a name="input_newrelic_resource_name_suffix"></a> [newrelic\_resource\_name\_suffix](#input\_newrelic\_resource\_name\_suffix) | n/a | `string` | `""` | no |
| <a name="input_newrelic_user"></a> [newrelic\_user](#input\_newrelic\_user) | NewRelic User | `string` | `""` | no |
| <a name="input_octopus_address"></a> [octopus\_address](#input\_octopus\_address) | Octopus URL | `string` | n/a | yes |
| <a name="input_octopus_api_key"></a> [octopus\_api\_key](#input\_octopus\_api\_key) | Octopus api key | `string` | `""` | no |
| <a name="input_octopus_environments"></a> [octopus\_environments](#input\_octopus\_environments) | The Octopus Environements | `list(string)` | `[]` | no |
| <a name="input_octopus_github_feed_name"></a> [octopus\_github\_feed\_name](#input\_octopus\_github\_feed\_name) | Octopus Github feed name | `string` | `"Github Container Registry"` | no |
| <a name="input_octopus_lifecycle_id"></a> [octopus\_lifecycle\_id](#input\_octopus\_lifecycle\_id) | The Octopus lifecycle id | `string` | `""` | no |
| <a name="input_octopus_organization_prefix"></a> [octopus\_organization\_prefix](#input\_octopus\_organization\_prefix) | The organization prefix for the deployment process script to build the full ECR URL | `string` | n/a | yes |
| <a name="input_octopus_project_group_name"></a> [octopus\_project\_group\_name](#input\_octopus\_project\_group\_name) | The Octopus Project group name | `string` | `""` | no |
| <a name="input_octopus_space_id"></a> [octopus\_space\_id](#input\_octopus\_space\_id) | The Octopus space id | `string` | `""` | no |
| <a name="input_octopus_worker_tools_version"></a> [octopus\_worker\_tools\_version](#input\_octopus\_worker\_tools\_version) | Octopus worker tools version | `string` | `"6.1-ubuntu.22.04"` | no |
| <a name="input_optional_steps"></a> [optional\_steps](#input\_optional\_steps) | n/a | `map` | `{}` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | Projects list | <pre>map(object({<br>    create_main_step = optional(bool, true)<br>    cronjobs         = optional(list(string), [])<br>    deployment_name  = optional(string, "")<br>    optional_steps = optional(map(object({<br>      name        = string<br>      is_required = optional(bool, true)<br>      properties  = map(string)<br>    })), {})<br>  }))</pre> | n/a | yes |
| <a name="input_registry_sufix"></a> [registry\_sufix](#input\_registry\_sufix) | n/a | `string` | `""` | no |
| <a name="input_slack_channel"></a> [slack\_channel](#input\_slack\_channel) | Slack channel | `string` | `""` | no |
| <a name="input_slack_webhook"></a> [slack\_webhook](#input\_slack\_webhook) | slack webhook | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_channels"></a> [channels](#output\_channels) | n/a |
| <a name="output_octopusdeploy_project"></a> [octopusdeploy\_project](#output\_octopusdeploy\_project) | n/a |
<!-- END_TF_DOCS -->
