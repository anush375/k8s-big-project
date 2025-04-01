#!/bin/sh

#set -e


ENVIRONMENT=$1
aws_region=$2
aws_access_key_id=$3
aws_secret_access_key=$4

echo "$ENVIRONMENT"
echo "$aws_region"


#---> Set up ingress-nginx

if [ "$(kubectl get ns ingress-nginx)" ];
then
  echo "Namespace ingress-nginx exist continue to chart installation"
else
  echo "Namespace does not exist creating ..."
  kubectl create ns ingress-nginx
fi


# Add the ingress-nginx helm repository:
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install the chart of ingress-nginx
helm upgrade --install  ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
if [ $? -ne 0 ];
then
  echo "Error installing ingress-nginx"
  exit 1;
fi





#---> Set up cert-manager

if [ "$(kubectl get ns cert-manager)" ];
then
  echo "Namespace cert-manager exist continue to chart installation"
else
  echo "Namespace does not exist creating ..."
  kubectl create ns cert-manager
fi


# Add the cert-manager helm repository:
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the cert-manager chart
helm upgrade --install \
   cert-manager jetstack/cert-manager \
   --namespace cert-manager \
   --set crds.enabled=true

if [ $? -ne 0 ];
then
  echo "Error installing cert-manager"
  exit 1;
fi

# Create secret acme-route53 for cert-manager ns

if [ "$(kubectl get secret acme-route53 -n cert-manager)" ];
then
  echo "Secret acme-route53 is already exist, skiping this step"
else
  echo "Secret does not exist, creating ..."
  kubectl create secret generic acme-route53 -n cert-manager --from-literal=secret-access-key=$aws_secret_access_key
fi

# Create cluster-issuer for cert manager

if [ "$(kubectl get clusterissuer)" ];
then
  echo "ClusterIssuer is already exist, skiping this step"
else
  echo "ClusterIssuer does not exist, creating ..."
  kubectl create -f cluster_issuers/cluster_issuer_prod.yaml
fi



#---> Set up external-dns

if [ "$(kubectl get ns external-dns)" ];
then
  echo "Namespace external-dns exist continue to chart installation"
else
  echo "Namespace does not exist creating ..."
  kubectl create ns external-dns
fi

# Add the cert-manager helm repository:
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update


# Install external-dns
helm upgrade --install  \
  external-dns \
  -n external-dns \
  --set aws.accessKey=$aws_access_key_id \
  --set aws.secretKey=$aws_secret_access_key \
  --set aws.region=$aws_region \
  --set policy=upsert-only \
  --set domainFilters={"prod.anushervon.life"} \
  external-dns/external-dns

if [ $? -ne 0 ];
then
  echo "Error installing external-dns"
  exit 1;
fi
