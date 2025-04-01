#!/bin/sh

#set -e


ENVIRONMENT=$1
aws_region=$2
aws_access_key_id=$3
aws_secret_access_key=$4

echo "$ENVIRONMENT"
echo "$aws_region"



#---> Add helm repo prometheus-loki

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


#---> Set up monitoring

if [ "$(kubectl get ns monitoring)" ];
then
  echo "Namespace monitoring exist continue to chart installation"
else
  echo "Namespace does not exist creating ..."
  kubectl create ns monitoring
fi


#---> Install the Prometheus-Operator and Grafana on monitoring namespace

helm upgrade --install thanos prometheus-community/kube-prometheus-stack -n monitoring -f grafana-prometheus/values/prometheus-stack/prom_stack_values_$ENVIRONMENT.yaml
if [ $? -ne 0 ];
then
  echo "Error installing prometheus-stack"
  exit 1;
fi


#---> Add helm repo loki

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update


#---> Install loki on monitoring
helm upgrade --install loki -n monitoring grafana/loki-stack
if [ $? -ne 0 ];
then
  echo "Error installing loki"
  exit 1;
fi
