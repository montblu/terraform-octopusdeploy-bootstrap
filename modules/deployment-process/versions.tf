terraform {
  required_version = ">= 1.1.0"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeploy/octopusdeploy"
      version = ">=1.1.1, <2.0.0"
    }
    curl2 = {
      source  = "DanielKoehler/curl2"
      version = "1.7.2"
    }
    env = {
      source = "tcarreira/env"
      version = "0.2.0"
    }
  }
}
