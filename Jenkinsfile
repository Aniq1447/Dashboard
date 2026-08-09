pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the GitHub repository
                git branch: 'main', url: 'https://github.com/Aniq1447/dashboard'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker logout" // Clears invalid stored Docker credentials
                    sh "docker container prune -f"
                    sh "docker image prune -a -f"
                    sh "docker builder prune --all --force"
                    sh "docker system prune -f"
                    sh "docker build -t react-app ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    // Define the Docker Hub credentials ID
                    def dockerHubCredentialId = 'docker-cred'
                    def dockerImageName = "aniq47/react-app:${BUILD_NUMBER}"

                    // Authenticate with Docker Hub using the credentials
                    withCredentials([usernamePassword(credentialsId: dockerHubCredentialId, passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        sh """
                        docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}
                        docker tag react-app ${dockerImageName}
                        docker push ${dockerImageName}
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    def awsCredentialsId = 'aws_creds'
                    
                    withCredentials([aws(credentialsId: awsCredentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh "aws eks --region us-east-1 update-kubeconfig --name eksdemo --kubeconfig ${WORKSPACE}/.kube/config"
                        sh "helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace --kubeconfig ${WORKSPACE}/.kube/config"
                        sh "helm upgrade --install react-app ./react-app-deployment/react-app --kubeconfig ${WORKSPACE}/.kube/config --set image.tag=${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
