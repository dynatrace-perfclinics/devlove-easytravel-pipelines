#!/bin/bash
# Bash functions to activate and deactivate problempatterns for EasyTravel.
# Simulate deployments for End2End testing and comparison of releases.

# Read deployment when no arguments
readDeploymentFromBuild() {
    EASYTRAVELDEPLOYMENT=$(cat _easytravel-cicd/MyBuildOutputs/easytravel.image)
    setVsoDeploymentVariable
}

setVsoDeploymentVariable() {
    echo "Read and set deployment: $EASYTRAVELDEPLOYMENT"
    echo "##vso[task.setvariable variable=EASYTRAVELDEPLOYMENT]$EASYTRAVELDEPLOYMENT"
}

# If parameters and == undoDeployment then call undoDeployment, else override deployment
doDeployment() {
    echo "Doing deployment via REST to 'http://rest.${DOMAIN}' for image tag:${EASYTRAVELDEPLOYMENT}"
    curl -v "http://rest.${DOMAIN}/services/ConfigurationService/setPluginEnabled?name=${EASYTRAVELDEPLOYMENT}&enabled=true"
}

undoDeployment() {
    echo "UnDoing deployment via REST to 'http://rest.${DOMAIN}' for image tag:${EASYTRAVELDEPLOYMENT}"
    curl -v "http://rest.${DOMAIN}/services/ConfigurationService/setPluginEnabled?name=${EASYTRAVELDEPLOYMENT}&enabled=false"
}

# If calling with a parameter undo deployment
if [[ $# -eq 0 ]]; then
    readDeploymentFromBuild
    doDeployment
elif [[ $1 == "undeploy" ]]; then
    # We undo the deployment. EASYTRAVELDEPLOYMENT should have been setted before either 
    # overriding or reading from image
    undoDeployment
else
    # Override deployment
    EASYTRAVELDEPLOYMENT=$1
    # Set it on the Build
    setVsoDeploymentVariable
    # Activate it over REST
    doDeployment 
fi
