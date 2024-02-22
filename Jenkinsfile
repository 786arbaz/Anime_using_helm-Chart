pipeline {
    agent any

    environment {
        // Define environment variables
        GITHUB_REPO_URL = 'https://github.com/786arbaz/786arbaz-Reddit-Copy-on-Kubernetes-with-Ingress.git'
        DOCKERFILE_PATH = 'Dockerfile'
        ACR_NAME = 'redditclone.azurecr.io'
        AZURE_CREDENTIALS_ID = 'Azure'
        HELM_CHART_PATH = 'Sakuna'
        HELM_RELEASE_NAME = 'Sakuna'
        K8S_NAMESPACE = 'default'
        K8S_CREDENTIALS_ID = 'k8s' // Update with your actual Kubernetes credentials ID
    }

    stages {
        stage('Checkout') {
            // Check out code from the GitHub repository
            steps {
                script {
                    echo "Checking out code from ${GITHUB_REPO_URL}"
                    git branch: 'master', credentialsId: 'github-cred', url: GITHUB_REPO_URL
                }
            }
        }

        stage('Build Docker Image') {
            // Build Docker image from the specified Dockerfile
            steps {
                script {
                    echo "Building Docker image from ${DOCKERFILE_PATH}"
                    sh "docker build -t Sakuna:${BUILD_NUMBER} -f ${DOCKERFILE_PATH} ."
                }
            }
        }

        stage('Push to ACR') {
            // Push Docker image to Azure Container Registry (ACR)
            steps {
                script {
                    echo "Pushing Docker image to ${ACR_NAME}.azurecr.io"
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID, )]) {
                        // Log in to Azure CLI using Service Principal credentials
                        sh "az login --service-principal --username \${AZURE_CLIENT_ID} --password \${AZURE_CLIENT_SECRET} --tenant \${AZURE_TENANT_ID}"

                        sh "az acr login --name ${ACR_NAME}"

                        // Tag the Docker image for ACR
                        sh "docker tag Sakuna:${BUILD_NUMBER} ${ACR_NAME}/Sakuna:${BUILD_NUMBER}"

                        // Push the Docker image to ACR
                        sh "docker push ${ACR_NAME}/Sakuna:${BUILD_NUMBER}"

                        // Log out from Azure CLI
                        sh "az logout"
                    }
                }
            }
        }

        stage('Update Helm Chart Version') {
            // Update appVersion in Helm Chart's Chart.yaml
            steps {
                script {
                    def updatedAppVersion = "${BUILD_NUMBER}"
                    // Update appVersion in Chart.yaml with the current build number
                    sh 'sed -i "s|appVersion: .*|appVersion: \"${updatedAppVersion}\"|" ${HELM_CHART_PATH}/Chart.yaml'

                }
            }
        }

        stage('Kubernetes and Helm Deployment') {
            // Deploy Helm chart to Kubernetes
            steps {
                script {
                    // Use withKubeConfig to set up Kubernetes credentials
                    withKubeConfig(
                        credentialsId: K8S_CREDENTIALS_ID,
                        serverUrl: '',
                        caCertificate: '',
                        namespace: K8S_NAMESPACE,
                        contextName: ''
                    ) {
                        // Deploy Helm chart
                        dir(HELM_CHART_PATH) {
                            sh "helm upgrade --install ${HELM_RELEASE_NAME} . --namespace=${K8S_NAMESPACE} --set image.repository=${ACR_NAME}/Sakuna,image.tag=${BUILD_NUMBER}"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            // Cleanup Jenkins workspace and remove Docker image if all stages are successful
            cleanWs()
            sh "docker rmi -f ${ACR_NAME}/Sakuna:${BUILD_NUMBER}"
        }
    }
}