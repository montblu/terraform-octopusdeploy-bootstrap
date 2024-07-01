terraform {
  required_version = ">= 0.13.1"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
      version = "0.14.8"
    }
    curl2 = {
      source  = "DanielKoehler/curl2"
      version = "1.7.2"
    }
  }
}