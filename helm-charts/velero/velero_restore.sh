#!/bin/sh

#set -e


ENVIRONMENT=$1
aws_region=$2
aws_access_key_id=$3
aws_secret_access_key=$4
EXCLUDE_NS="default,kube-system,kube-node-lease,kube-public,velero,cert-manager,external-dns,ingress-nginx"

echo "$ENVIRONMENT"
echo "$aws_region"


#---> Restore from PROD to DR
# Pulling latest backup
export BACKUP_NAME=$(velero backup get | awk {'print $1'} | head -2 | grep -i prod)
if [ $? -ne 0 ];
then
  echo "Error creating variable for backup ID"
  exit 1;
fi

if [ $ENVIRONMENT == "dr" ];
then
  echo "Restoring backup to DR cluster"
  velero restore create --from-backup $BACKUP_NAME
fi

if [ $? -ne 0 ];
then
  echo "Error restoring backup"
  exit 1;
fi