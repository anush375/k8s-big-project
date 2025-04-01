#!/usr/bin/env groovy
import groovy.transform.Field
import groovy.lang.Binding

pipeline {
    agent any
    stages {
       stage('Docker build') {
            agent any
            environment {
                    IMAGE_TAG = "base_${env.BUILD_ID}"
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
                    IMAGE_TAG = "base_${env.BUILD_ID}"
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
                    IMAGE_TAG = "base_${env.BUILD_ID}"
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