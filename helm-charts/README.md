### helm-charts

This code creates the following set up.

# Ingress-nginx

In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster. You configure access by creating a collection of rules that define which inbound connections reach which services. This lets you consolidate your routing rules into a single resource

Installation process


# Add the ingress-nginx helm repository:
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

# Install the chart of ingress-nginx
```
helm upgrade --install  ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
```

### External-DNS

ExternalDNS is a Kubernetes addon that configures public DNS servers with information about exposed Kubernetes services to make them discoverable.

# Add the cert-manager helm repository:
```
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update
```

# Install external-dns

```
helm upgrade --install  \
  external-dns \
  -n external-dns \
  --set aws.accessKey=$aws_access_key_id \
  --set aws.secretKey=$aws_secret_access_key \
  --set aws.region=$aws_region \
  --set policy=upsert-only \
  --set domainFilters={$ENVIRONMENT.versoview.us} \
  external-dns/external-dns
```


### Cert-manager

cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources.
It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

# Add the cert-manager helm repository:
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

# Install the cert-manager chart
```
helm upgrade --install \
   cert-manager jetstack/cert-manager \
   --namespace cert-manager \
   --set installCRDs=true
```