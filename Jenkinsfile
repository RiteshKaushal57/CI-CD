pipeline {
    agent any

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

        stage('Build & Push Docker Images') {
            steps {
                script {
                    def services = [
                        "api-gateway",
                        "auth-service",
                        "order-service",
                        "frontend"
                    ]

                    services.each { service ->
                        dir("CI/${service}") {
                            sh """
                              docker build -t ${REGISTRY}/${service}:${IMAGE_TAG} .
                              docker push ${REGISTRY}/${service}:${IMAGE_TAG}
                            """
                        }
                    }
                }
            }
        }

        stage('Update GitOps Repo') {
            steps {
                script {
                    def services = [
                        "api-gateway",
                        "auth-service",
                        "order-service",
                        "frontend"
                    ]

                    dir("CD/helm/mern-chart") {
                        services.each { service ->
                            sh """
                              yq -i '.services.${service}.tag = "${IMAGE_TAG}"' values.yaml
                            """
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
