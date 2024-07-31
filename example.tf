module "test_inception" {
source = "./modules/octopus_inception"
environment = var.environment
octopus_project_group_name = var.octopus_project_group_name 
lifecycles = var.lifecycles
create_space = var.create_space
}

module "test_k8s-connector" {
source = "./modules/octopus_k8s-connector"

environment = var.environment
registry_prefix = "ramp"
octopus_dockerhub_feed_name = var.octopus_dockerhub_feed_name

octopus_environments = module.test_inception.octopus_environments
octopus_space_id = module.test_inception.octopus_space_id

k8s_cluster_url = data.aws_eks_cluster.eks_cluster.endpoint
k8s_account_token = lookup(data.kubernetes_secret.octopus_token.data, "token")
k8s_namespace = "ramp-${var.environment}"
k8s_container_image = "montblu/workertools:${var.octopus_worker_tools_version}"
k8s_certificate_data = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
k8s_certificate_password = "NOT USED"
depends_on = [ module.test_inception ]
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

deployment_projects = var.deployment_projects

enable_newrelic = false
newrelic_apikey = "AQICAHjmKIav4JqyzyMDG4PQ+ZtIc2PgaF2z/pbtlJHR+bWcswEypxyHkrw7KgC7xfQvr4mEAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMCx9zXSa4C3TloKOwAgEQgDuRy/ikCAbxvXNqGg17mC9yUVWelWUtW8vCdbQ6d39XCHHkBqBNBG3Z7I3XLYamM5ZZSRayS3FAso0wSw=="
newrelic_user = ""

enable_slack = false
slack_webhook = "AQICAHjmKIav4JqyzyMDG4PQ+ZtIc2PgaF2z/pbtlJHR+bWcswGaJNtppAnnBF4DzzhAfLeNAAAAsTCBrgYJKoZIhvcNAQcGoIGgMIGdAgEAMIGXBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDOnORGgbxqw82kEgsAIBEIBq/cAZUlYNMeAOMG/xLbuzGbbmhSK997IAKBn+J+JCfwwYTTqjqZZ5bRfJOHVpZhkTTh4W+hPH78BXYyT5jxssYyVfjVd1sRAZFIobYvgZajmqg5NTIT934fiToQgjRVM9siZxBdY1fZUTOg=="

depends_on = [ module.test_k8s-connector ]
}
