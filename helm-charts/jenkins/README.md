https://github.com/jenkinsci/helm-charts


helm repo add jenkins https://charts.jenkins.io

k create ns jenkins

helm upgrade --install jenkins jenkins/jenkins -n jenkins -f values.yaml



Username: admin:

Get admin password:
printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

Kubernetes Continuous Deployn


Jenkins Plugins: 
Docker, Kubernetes
Role-based Authorization Strategy

https://plugins.jenkins.io/authorize-project/

# Under globas security enable role based strategy
