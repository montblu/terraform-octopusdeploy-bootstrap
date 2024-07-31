terraform {
  required_version = ">= 0.14"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
      version = "0.22.0"
    }
  }
}
