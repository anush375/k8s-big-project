kubectl -n kube-system describe secret eks-admin-token-v54fk

kubectl proxy
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/\#!/login.
