pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/sleep
    args:
    - "999999"
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    - name: workspace-volume
      mountPath: /home/jenkins/agent

  - name: tools
    image: ritesh57/ci-tools:1.0
    command:
    - cat
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent

  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-creds
      items:
      - key: .dockerconfigjson
        path: config.json

  - name: workspace-volume
    emptyDir: {}
"""
    }
  }

  environment {
    REGISTRY = "ritesh57"
    IMAGE_TAG = "${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Images (Kaniko)') {
      steps {
        container('kaniko') {
          script {
            def services = [
              "api-gateway",
              "auth-service",
              "order-service",
              "frontend"
            ]

            services.each { service ->
              sh """
                /kaniko/executor \
                  --context ${WORKSPACE}/CI/${service} \
                  --dockerfile ${WORKSPACE}/CI/${service}/Dockerfile \
                  --destination ${REGISTRY}/${service}:${IMAGE_TAG} \
                  --verbosity=info
              """
            }
          }
        }
      }
    }

    stage('Update GitOps Repo') {
      steps {
        container('tools') {
          script {
            def services = [
              "api-gateway",
              "auth-service",
              "order-service",
              "frontend"
            ]

            dir("CD/helm/mern-chart") {
              services.each { service ->
                sh "yq -i '.services.${service}.tag = \"${IMAGE_TAG}\"' values.yaml"
              }

              sh """
                git add values.yaml
                git commit -m "Update images to ${IMAGE_TAG}"
                git push origin main
              """
            }
          }
        }
      }
    }
  }
}
