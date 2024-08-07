terraform {
  required_version = ">= 0.13.1"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
      version = "0.22.0"
    }
  }
}