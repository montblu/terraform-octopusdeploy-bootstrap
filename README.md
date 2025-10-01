# terraform-octopusdeploy-bootstrap

Simple Terraform module used to manage a Octopus instance

## Modules

- [deployment-process](modules/deployment-process)
- [inception](modules/inception)
- [k8s-connector](modules/k8s-connector)

## Breaking changes

### Upgrading to v7.x

Upgrading the [deployment-process](modules/deployment-process) module requires manual action.
Check [module documentation](modules/deployment-process/README.md) for migration instructions.

### Upgrading to v6.x

Requires replacing the provider. Check the official documentation:
https://registry.terraform.io/providers/OctopusDeploy/octopusdeploy/latest/docs/guides/moving-from-octopus-deploy-labs-nam

