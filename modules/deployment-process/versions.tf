terraform {
  required_version = ">= 1.1.0"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
      version = "0.22.0"
    }
    curl2 = {
      source  = "DanielKoehler/curl2"
      version = "1.7.2"
    }
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.27.7"
    }
  }
}

