# Doc for loki installation

https://grafana.com/docs/loki/latest/installation/helm/

query for loki:   {namespace="kube-system"}

# Prometheus community helm

https://github.com/prometheus-community/helm-charts/tree/main/charts

# tutorial 
https://ystatit.medium.com/install-prometheus-and-grafana-using-helm-b83b5018a1c4

# Helm commands
helm upgrade --install prometheus -n monitoring -f values.yaml .
helm dependencies update


# Urls
DEV:
https://alertmanager.dev.versoview.us/#/status
https://prometheus.dev.versoview.us/#/status
https://alertmanager.dev.versoview.us/

QA:
https://grafana.qa.versoview.us/
https://prometheus.qa.versoview.us/
https://alertmanager.qa.versoview.us/

# Install metric server
https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

# Grafana

 admin-password: prom-operator
  admin-user: admin

# Dasboards:

pod cpu and memory usage: 15055
memorry per namespace:    13421
Node all memory cpu:      1860
Cluster cpu and memory:   315
Network:                  6663


# SMTP server config
k get cm thanos-grafana -n monitoring

 grafana.ini: |
    [analytics]
    check_for_updates = true
    [grafana_net]
    url = https://grafana.net
    [log]
    mode = console
    [paths]
    data = /var/lib/grafana/
    logs = /var/log/grafana
    plugins = /var/lib/grafana/plugins
    provisioning = /etc/grafana/provisioning
    [smtp]
    enabled = true
    host = smtp.office365.com:587
    user = versoview.user@alphait.us
    password = Alph@704
    skip_verify = true
    from_address = versoview.user@alphait.us


And then restart grafana.



roman.pereverziev@alphait.us,shrey.upadhyay@alphait.us,manmohan.singh@alphait.us,mohammad.siddiq@alphait.us
