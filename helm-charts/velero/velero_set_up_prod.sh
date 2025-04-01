#!/bin/sh

#set -e


ENVIRONMENT=$1
aws_region=$2
aws_access_key_id=$3
aws_secret_access_key=$4
EXCLUDE_NS="default,kube-system,kube-node-lease,kube-public,velero,cert-manager,external-dns,ingress-nginx,monitoring,kubernetes-dashboard"

echo "$ENVIRONMENT"
echo "$aws_region"


#---> Set up velero on prod and dr

velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.0.1 \
    --bucket valero-backup-prod \
    --backup-location-config region=ap-south-1 \
    --snapshot-location-config region=ap-southeast-1 \
    --secret-file /root/.aws/credentials

if [ $? -ne 0 ];
then
  echo "Error installing velero"
  exit 1;
fi

if [ $ENVIRONMENT == "prod" ];
then
  echo "Schedulling backup on prod cluster"
  velero schedule create prod-backup --schedule="@every 2h" --exclude-namespaces $EXCLUDE_NS --ttl=72h
fi

if [ $? -ne 0 ];
then
  echo "Error schedulling backup velero"
  exit 1;
fi

