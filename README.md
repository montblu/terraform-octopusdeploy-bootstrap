# terraform-octopusdeploy-bootstrap
 Simple Terraform module used to manage a Octopus instance

Example: 

module "test_inception" {
source = "./modules/octopus_inception"
environment = var.environment

octopus_project_group_name = "ramp"
octopus_environments = [ "stage", "test", "demo", "prod" ]
lifecycles = [ ]
}

module "test_deployment" {
source = "./modules/octopus_deployment_process"
environment = var.environment
octopus_address = "https://filingramp.octopus.app"
octopus_dockerhub_feed_name = "GitHub"

octopus_environments = module.test_inception.octopus_environments
octopus_project_group_name = module.test_inception.octopus_project_group_name
octopus_space_id = module.test_inception.octopus_space_id
octopus_lifecycle_id = module.test_inception.octopus_lifecycle

k8s_registry_url = "360379118495.dkr.ecr.us-east-1.amazonaws.com"
registry_prefix = "ramp"
registry_sufix = "sufix"

deployment_projects = {
  "analytics-service" = {},
  "auth-service" = {},
  "clone-service" = {},
  "document-content-service" = {},
  "drive-service" = {
    cronjobs = [
     "drive-cronjob",
]},

  "event-service" = {
    cronjobs = [
      "reminder-cronjob",
      "event-cronjob", 
  ]},
  "serff-spi-service" = {},
  "filing-import-service" = {},
  "library-service" = {},
  "messaging-service" = {},
  "mozart-service" = {},
  "notification-service" = {},
  "reporting-service" = {},
  "search-service" = {},
  "serff-polling-service" = {},
  "sync-service" = {},
  "web-api" = {}, 
}

enable_newrelic = false
newrelic_apikey = "AQICAHjmKIav4JqyzyMDG4PQ+ZtIc2PgaF2z/pbtlJHR+bWcswEypxyHkrw7KgC7xfQvr4mEAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMCx9zXSa4C3TloKOwAgEQgDuRy/ikCAbxvXNqGg17mC9yUVWelWUtW8vCdbQ6d39XCHHkBqBNBG3Z7I3XLYamM5ZZSRayS3FAso0wSw=="
newrelic_user = ""

enable_slack = false
slack_webhook = "AQICAHjmKIav4JqyzyMDG4PQ+ZtIc2PgaF2z/pbtlJHR+bWcswGaJNtppAnnBF4DzzhAfLeNAAAAsTCBrgYJKoZIhvcNAQcGoIGgMIGdAgEAMIGXBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDOnORGgbxqw82kEgsAIBEIBq/cAZUlYNMeAOMG/xLbuzGbbmhSK997IAKBn+J+JCfwwYTTqjqZZ5bRfJOHVpZhkTTh4W+hPH78BXYyT5jxssYyVfjVd1sRAZFIobYvgZajmqg5NTIT934fiToQgjRVM9siZxBdY1fZUTOg=="

depends_on = [ module.test_inception ]
}

