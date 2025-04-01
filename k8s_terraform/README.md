# This page is used to set up eks cluster on top of AWS.


Dockerfile ---->  is used as a runtime for our terraform job, jenkins server will pull that image and execute code inside it. That way it will help us to isolate the processes.  It has list of the nececary packages inside as well as TF repo cloned to the image.

Note: If you are changing terraform code you have to rebuil that image with Jenkinsfile.

```
FROM alpine:3.10
ENV TERRAFORM_VERSION=0.13.5
ENV KUBECTL_VERSION=v1.18.2
ENV HELM_VERSION=v3.2.4

WORKDIR /app

RUN apk --no-cache update \
  && apk upgrade \
  && apk --no-cache add curl git wget unzip openssh jq bind-tools bash python \
  && wget /app https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O terraform.zip ; unzip /app/terraform.zip \
  && chmod +x /app/terraform; mv /app/terraform /usr/local/bin/; rm /app/terraform.zip \
  && wget --no-check-certificate -P /app https://get.helm.sh/helm-$HELM_VERSION-linux-386.tar.gz ; tar -xzvf /app/helm-$HELM_VERSION-linux-386.tar.gz \
  && mv /app/linux-386/helm /usr/local/bin/helm; rm /app/helm-$HELM_VERSION-linux-386.tar.gz \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl; chmod +x /app/kubectl; mv /app/kubectl /usr/local/bin/ \
  && apk add --no-cache python3 py3-pip


RUN apk update && apk add \
	ca-certificates \
	groff \
	less \
	python \
	py-pip \
	&& rm -rf /var/cache/apk/* \
  && pip install pip --upgrade \
  && pip install awscli

COPY alpha-tech-eks-terraform/heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin
COPY alpha-tech-eks-terraform .
```
Jenkinsfile ----->     Used to build base image for creating EKS cluster, whenever you rerun it dont forget to update base image inside <Jenkinsfile_tf_apply> and <Jenkinsfile_tf_destroy> on bellow line:

```
    docker {
        image 'versoview/base-image:eks_dev_1'
    }
```


Jenkinsfile_tf_apply       ----> Used to create the actual cluster just import this file to jenkins pipeline.

```
// a.groovy
import groovy.transform.Field
import groovy.lang.Binding
pipeline {
    agent any
    stages {
        stage('Terraform init/plan/apply') {
            agent {
                docker {
                    image 'versoview/base-image:eks_dev_1'
                    registryUrl 'https://registry.hub.docker.com'
                    args '-u root:root'
                    registryCredentialsId 'dockerhub_generic'
                }
            }
            environment {
                aws_access_key_id = credentials('aws_access_key_id')
                aws_secret_access_key = credentials('aws_secret_access_key')
                aws_region = 'ap-southeast-1'
                environment = 'dev'
            }
            steps {
                sh "aws configure set aws_access_key_id ${aws_access_key_id}"
                sh "aws configure set aws_secret_access_key ${aws_secret_access_key}"
                sh "aws configure set default.region ${aws_region}"
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    terraform init
                    terraform plan --var-file=values.tfvars 
                    '''
                timeout(time:1, unit:'HOURS') {
                    input("Proceed to apply DEV-EKS ?")
                }
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    pwd
                    terraform apply --var-file=values.tfvars --auto-approve=true
                    mkdir ~/.kube
                    terraform output kubeconfig > ~/.kube/config
                    aws eks --region ${aws_region} update-kubeconfig --name terraform-eks-${environment}
                    terraform output config-map-aws-auth > config-map-aws-auth.yaml
                    export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
                    kubectl apply -f config-map-aws-auth.yaml
                    kubectl get nodes
                    cat ~/.kube/config
                    '''
                }
                }
            }
        }
    }
}
```

Jenkinsfile_tf_destroy     ----> Used to destroy the cluster (be cearful with this pipeline).

```
// a.groovy
import groovy.transform.Field
import groovy.lang.Binding
pipeline {
    agent any
    stages {
        stage('Terraform destroy') {
            agent {
                docker {
                    image 'versoview/base-image:eks_dev_1'
                    registryUrl 'https://registry.hub.docker.com'
                    args '-u root:root'
                    registryCredentialsId 'dockerhub_generic'
                }
            }
            environment {
                aws_access_key_id = credentials('aws_access_key_id')
                aws_secret_access_key = credentials('aws_secret_access_key')
                aws_region = 'ap-southeast-1'
                environment = 'dev'
            }
            steps {
                sh "aws configure set aws_access_key_id ${aws_access_key_id}"
                sh "aws configure set aws_secret_access_key ${aws_secret_access_key}"
                sh "aws configure set default.region ${aws_region}"
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    terraform init
                    terraform plan --var-file=values.tfvars 
                    '''
                timeout(time:1, unit:'HOURS') {
                    input("Proceed to destroy DEV-EKS ?")
                }
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    pwd
                    terraform destroy --var-file=values.tfvars --auto-approve=true
                    '''
                }
                }
            }
        }
    }
}
```


values.tfvars              ----> is a variables storage so if you need to make your modifications and install cluster to different region update this file.

```
cluster-name = "terraform-eks-dev"
vpc_id = "vpc-0daa69bb1d5a65662"
env = "dev"
region = "ap-southeast-1"
public_subnets = ["subnet-01b0418aee7e852df", "subnet-0bf04db20c8f4dac4", "subnet-0544b876043ff43b4"]
image_id = "ami-02a3a200c350cb674"
```


eks-workers.tf           -----> has worker nodes configuration as well as autoscalling group, so if you need to make a change to desired or min/max amout of workers update those details.

```
resource "aws_autoscaling_group" "cluster_eks" {
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.cluster_eks.id
  max_size = 2
  min_size = 1
}
```




Bellow is the notes with manual steps.

# AWS page with optimized AMI id's

https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html

# Setting up AWS EKS (Hosted Kubernetes)

See https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html for full guide


## Download kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin


## Download the aws-iam-authenticator

wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/heptio-authenticator-aws


## Modify providers.tf

Choose your region. EKS is not available in every region, use the Region Table to check whether your region is supported: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

Make changes in providers.tf accordingly (region, optionally profile)

## Terraform apply

terraform init
terraform apply


## Configure kubectl

terraform output kubeconfig # save output in ~/.kube/config
aws eks --region <region> update-kubeconfig --name terraform-eks-dev


## Configure config-map-auth-aws

terraform output config-map-aws-auth # save output in config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml


## See nodes coming up

kubectl get nodes


## Save and Export kubeconfig to your own path

export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config_alpha/config_dev 

## Create test app
kubectl create ns app-nginx
kubectl create -f manifests/test-app-nginx/deployment-svc-nginx.yaml

## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:

terraform destroy
