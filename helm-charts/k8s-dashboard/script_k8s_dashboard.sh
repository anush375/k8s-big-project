#!/bin/sh

#set -e


ENVIRONMENT=$1
echo "$ENVIRONMENT"


# Create k8s dashboard main resources
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
if [ $? -ne 0 ];
then
  echo "Error creating k8s-dashboard"
  exit 1;
fi


#--->  Create ingress and admin Service Account for k8s-dashboard

kubectl apply -f k8s-dashboard/manifests/admin_sa.yaml
if [ $? -ne 0 ];
then
  echo "Error creating Service Account for k8s-dashboard"
  exit 1;
fi

kubectl apply -f k8s-dashboard/manifests/ingress_$ENVIRONMENT.yaml
if [ $? -ne 0 ];
then
  echo "Error creating Ingress for k8s-dashboard"
  exit 1;
fi


# Get admin tocket for accessing k8s dashboard

kubectl get secret $(kubectl get serviceaccount dashboard-admin -n kube-system -o jsonpath="{.secrets[0].name}") -n kube-system -o jsonpath="{.data.token}" | base64 -d

if [ $? -ne 0 ];
then
  echo "Error getting tocken for k8s-dashboard"
  exit 1;
fi