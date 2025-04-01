
# Velero cheet sheet.

### Create backup of EKS

```
velero backup create <backupname> --include-namespaces <namespacename>
```

### List backups created
```
velero get backup
```

### Get most recent backup

```
velero backup get | awk {'print $1'} | head -2 | grep -i prod
```

### Describe backup (--details is optional flag to see more details).
```
velero describe backup <backup_name> --details
```


### Restore backup 
```
velero restore create --from-backup <backup_name>
```

### Schdedulle backup
```
velero schedule create <backup_name> --schedule="@every 2h" --exclude-namespaces  default,kube-system,kube-node-lease,kube-public,velero,cert-manager,external-dns,ingress-nginx
```

### Delete schedulle 
```
velero delete schedule <schedule_name> -n velero
```
