terraform {
  required_version = ">= 1.1.0"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeploy/octopusdeploy"
      version = ">=1.1.1, <2.0.0"
    }
  }
}
