#!/bin/sh
set -e

helm repo add jenkins https://charts.jenkins.io

k create ns jenkins

helm upgrade --install jenkins jenkins/jenkins -n jenkins -f values.yaml


# Get admin password:
printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo