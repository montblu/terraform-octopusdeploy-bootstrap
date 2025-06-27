terraform {
  required_version = ">= 1.1.0"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeploy/octopusdeploy"
      version = "~> 1.0.1"
    }
    curl2 = {
      source  = "DanielKoehler/curl2"
      version = "1.7.2"
    }
  }
}
