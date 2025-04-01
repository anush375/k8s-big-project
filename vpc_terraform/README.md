# Standard VPC

This module is for a standard VPC build. Which will consist of bellow resources:

* VPC creation (/8)
* NAT gateway
* Internet gateway
* 4 public subnets (/24)
* 4 private subnets (/24)
* Routes for public subnets to internet gateway
* Routes for private subnets to NAT gateway
* Security groups to modify

# This code is using terraform to spin up infrastructure and Jenkins CI/CD as a deployment tool

# In order to change variable for deploying to different region or creating different env use bellow file.


values.tfvars
```
vpc_name = "dev-vpc"
octet = "100"
region = "ap-southeast-1"
```
Replace above values based on your set up.

# There commands to run your terraform code in order to build VPC, commands are triggered as part of Jenkins CI/CD pipelines.
terraform init
terraform plan --var-file=values.tfvars 
terraform apply --var-file=values.tfvars


# Jenkins groovy script and its purpose.

Jenkinsfile                --->  Used to create base image with leyers nececary to it.

```
#!/usr/bin/env groovy
import groovy.transform.Field
import groovy.lang.Binding

pipeline {
    agent any
    stages {
       stage('Docker build') {
            agent any
            environment {
                    IMAGE_TAG = "${env.BUILD_ID}"
                    registry = 'https://registry.hub.docker.com'
                    repository = 'versoview/base-image'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_generic', usernameVariable: 'username', passwordVariable: 'password')]){
                    sh 'docker login -u ${username} -p ${password} ${registry}'
                    sh 'docker build . -t ${repository}:${IMAGE_TAG}'
                    }
            }
       }
       stage('Docker push') {
            agent any
            environment {
                    IMAGE_TAG = "${env.BUILD_ID}"
                    repository = 'versoview/base-image'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_generic', usernameVariable: 'username', passwordVariable: 'password')]){
                    sh 'docker login -u ${username} -p ${password} ${registry}'
                    sh 'docker push ${repository}:${IMAGE_TAG}'
                }
            }
       }
       stage('Clean up after completion') {
            agent any
            environment {
                    IMAGE_TAG = "${env.BUILD_ID}"
                    repository = 'versoview/base-image'
            }
            steps {
                    sh "docker rmi ${repository}:${IMAGE_TAG}"
            }
       }
    }
    post { 
        always { 
            cleanWs()
        }
    }
}
```

Jenkinsfile_tf             --->  To deploy VPC to the AWS region.

```
// a.groovy
import groovy.transform.Field
import groovy.lang.Binding
pipeline {
    agent any
    stages {
        stage('Terraform init and plan') {
            agent {label 'alpha-ansible-dev-sg-node'} 
            environment {
                aws_access_key_id = credentials('aws_access_key_id')
                aws_secret_access_key = credentials('aws_secret_access_key')
                aws_region = 'ap-southeast-1'
            }
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GitHub personal access token', url: 'https://github.com/Alpha-TechUSA/vpc_terraform.git']]])
                sh "ls -lart ./*"
                sh "aws configure set aws_access_key_id ${aws_access_key_id}"
                sh "aws configure set aws_secret_access_key ${aws_secret_access_key}"
                sh "aws configure set default.region ${aws_region}"
                script {
                    sh '''
                    cd alpha_tech_vpc_terraform
                    terraform init
                    terraform plan --var-file=values.tfvars 
                    '''
                }
            }
        }
        stage('Terraform apply') {
            agent {label 'alpha-ansible-dev-sg-node'} 
            steps {
                timeout(time:8, unit:'HOURS') {
                    input("Proceed to apply DEV VPC ?")
                }
                script {
                    sh '''
                    cd alpha_tech_vpc_terraform
                    terraform apply --var-file=values.tfvars --auto-approve=true
                    '''
                }
                }
            }
        }
        post { 
        always { 
            cleanWs()
        }
    }
}  
```

Jenkinsfile_tf_destroy     --->  To destroy VPC (if you go to destroy it make sure there norsources on that VPC).

```
// a.groovy
import groovy.transform.Field
import groovy.lang.Binding
pipeline {
    agent any
    stages {
        stage('Terraform init and plan') {
            agent {label 'alpha-ansible-dev-sg-node'} 
            environment {
                aws_access_key_id = credentials('aws_access_key_id')
                aws_secret_access_key = credentials('aws_secret_access_key')
                aws_region = 'ap-southeast-1'
            }
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GitHub personal access token', url: 'https://github.com/Alpha-TechUSA/vpc_terraform.git']]])
                sh "ls -lart ./*"
                sh "aws configure set aws_access_key_id ${aws_access_key_id}"
                sh "aws configure set aws_secret_access_key ${aws_secret_access_key}"
                sh "aws configure set default.region ${aws_region}"
                script {
                    sh '''
                    cd alpha_tech_vpc_terraform
                    terraform init
                    terraform plan --var-file=values.tfvars 
                    '''
                }
            }
        }
        stage('Terraform destroy') {
            agent {label 'alpha-ansible-dev-sg-node'} 
            steps {
                timeout(time:8, unit:'HOURS') {
                    input("Proceed to destroy DEV VPC ?")
                }
                script {
                    sh '''
                    cd alpha_tech_vpc_terraform
                    terraform destroy --var-file=values.tfvars --auto-approve=true
                    '''
                }
                }
            }
        }
        post { 
        always { 
            cleanWs()
        }
    }
}  
```


# Urls for jenkins pipelines

Base image

```
http://18.140.90.37:8080/view/Infrastructure_DevOps/job/base-image-build/
```

Deploy VPC

```
http://18.140.90.37:8080/view/Infrastructure_DevOps/job/vpc_terraform/
```

Destroy VPC

```
http://18.140.90.37:8080/view/Infrastructure_DevOps/job/terraform_vpc_destroy/
```
