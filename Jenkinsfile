pipeline {
    agent any 
    
    environment{
        cred = credentials('aws-key') // AWS access key için tanımlı credential
        dockerhub_cred = credentials('docker-cred') // Docker Hub için tanımlı credential
        DOCKER_IMAGE = "bayramozkan/jenkins-cicd"
        DOCKER_TAG = "$BUILD_NUMBER"
        SONARQUBE_URL = 'http://localhost:9000/'
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }
    stages{
        
        stage("Git Checkout"){ // Repository checkout işlemi
            steps{
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/nakzoo/jenkins-java.git'
            }
        }
          
        
       stage("MVN build"){ // Maven build aşaması
            steps{
                // sh "mvn clean install -Dmaven.test.skip=true"
                sh "mvn clean install -Dmaven.test.skip=true -U"

            }
        }

        stage('SonarQube Analysis') { // SonarQube kod analizi
           steps {
                sh """
                    mvn sonar:sonar \
                    -Dsonar.projectKey=jenkins-java \
                    -Dsonar.host.url=${SONARQUBE_URL} \
                    -Dsonar.login=${SONAR_TOKEN} \
                    -Dsonar.java.binaries=target/classes
                """
            }    
        }
        
       stage("Docker Build & Push"){  // Docker image build ve push aşaması
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {                        
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }
        
        stage("Update Kubernetes Manifest"){  // Kubernetes manifest dosyasını güncelleme
            steps{
                sh "sed -i 's|bayramozkan/jenkins-cicd:java|${DOCKER_IMAGE}:${DOCKER_TAG}|' manifest/deployment.yaml"
            }
        }

        // trivy bypass 
        // stage("TRIVY"){ // Docker image security kontrollü
        //     steps{
        //          sh "trivy image --scanners vuln ${DOCKER_IMAGE}:${DOCKER_TAG}"
                  

        //     }
        // }

        stage("Deploy To EKS"){  // EKS'e deployment yapma
            steps{
                sh 'aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster'
                sh 'kubectl apply -f manifest/deployment.yaml'
            }
        }
    }
    
    post {
        always {
            echo "Job is completed"
        }
        success {
            echo "It is a success"
        }
        failure {
            echo "Job is failed"
        }
    }
}
    
