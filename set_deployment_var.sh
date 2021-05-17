#!/bin/bash

setVars() {

    echo "Deployment based on time:$EASYTRAVELDEPLOYMENT"

    echo "##vso[task.setvariable variable=EASYTRAVELDEPLOYMENT]$EASYTRAVELDEPLOYMENT"

    echo $EASYTRAVELDEPLOYMENT >easytravel.image
}


calculateDeployment() {
    #Date in 12 Hour format (01-12)
    h=$(date +"%I")
    echo "H is $h"

    case $h in
    "12" | "06")
        EASYTRAVELDEPLOYMENT="None"
        ;;
    "01" | "07")
        EASYTRAVELDEPLOYMENT="CPULoadJourneyService"
        ;;
    "02" | "08")
        EASYTRAVELDEPLOYMENT="DBSpammingAuthWithAppDeployment"
        ;;
    "03" | "09")
        EASYTRAVELDEPLOYMENT="LoginProblems"
        ;;
    "04" | "10")
        EASYTRAVELDEPLOYMENT="JourneyUpdateSlow"
        ;;
    "05" | "11")
        EASYTRAVELDEPLOYMENT="CreditCardCheckError500"
        ;;
    esac
}

calculateDeployment
setVars