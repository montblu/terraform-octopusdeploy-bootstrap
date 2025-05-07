locals {
  set_image_script_body = <<-EOT
#!/bin/bash

set -e

ENVIRONMENT="$(get_octopusvariable "Octopus.Environment.Name")"
PROJECTNAME="$(get_octopusvariable "Octopus.Project.Name")"
DEPLOYMENT="$(get_octopusvariable "deployment_name")"
RELEASENUMBER="$(get_octopusvariable "Octopus.Release.Number")"
DOCKER_IMAGE="$(get_octopusvariable "ecr_url")/$DEPLOYMENT:$RELEASENUMBER"
# Get list of all the containers in the Deployment including init containers
IFS=" " read -r -a ALL_CONTAINERS <<< "$(kubectl get deployment $DEPLOYMENT -o jsonpath="{.spec.template.spec.containers[*].name} {.spec.template.spec.initContainers[*].name}")"
# Container names selected from the value coming from annotation 'octopus.containers.set' in the deployment
OCTOPUS_ANNOTATION=$(kubectl get deployment $DEPLOYMENT -o jsonpath="{.metadata.annotations.octopus\.containers\.set}")
CONTAINERS=()

if [ -z "$OCTOPUS_ANNOTATION" ]
then
    # If the annotation is missing or empty we set the image for all containers
    SELECTED_CONTAINERS=("$${ALL_CONTAINERS[@]}")
else
    # Otherwise we use the containers from the annotation
    IFS="," read -a SELECTED_CONTAINERS <<< "$OCTOPUS_ANNOTATION"
fi

# Create an array with container names and image Ex:["container1=image" "container2=image"]
for container in "$${SELECTED_CONTAINERS[@]}"
do
    CONTAINERS+=( "$container=$DOCKER_IMAGE" )
done

# Set Image to the containers
kubectl set image "deployment/$DEPLOYMENT" $${CONTAINERS[@]}

# Wait for deployment to became Healthy
kubectl rollout status "deployment/$DEPLOYMENT"
EOT

}
