pipeline {
    agent { label 'Jenkins-Agent' }
    
    tools {
        jdk 'jdk-17'
        maven 'maven'
    }
  
    environment {
        APP_NAME          = "register-app"
        RELEASE           = "1.0.0"
        IMAGE_NAME        = "zeyadelnashashky/${APP_NAME}"
        IMAGE_TAG         = "${RELEASE}-${BUILD_NUMBER}"
        
        DOCKER_CREDS_ID   = 'dockerhub'
        SONAR_CREDS_ID    = 'jenkins-sonarqube-token'
        GITHUB_CREDS_ID   = 'gitHub'
    }
    
    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout from SCM") {
            steps {
                git branch: 'main', credentialsId: "${GITHUB_CREDS_ID}", url: 'https://github.com/zeyadelnashasky/Registeration-App.git'
            }
        }

        stage("Build & Test Application") {
            steps {
                sh "mvn clean package"
            }
        }

        stage("SonarQube Analysis") {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: "${SONAR_CREDS_ID}") { 
                        sh "mvn sonar:sonar"
                    }
                }   
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: true, credentialsId: "${SONAR_CREDS_ID}"
                }   
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_CREDS_ID}") {
                        def docker_image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        docker_image.push()
                        docker_image.push('latest')
                    }
                }
            }
        }

        stage("Trivy Scan") {
            steps {
                script {
                    sh "docker run --rm aquasec/trivy image --no-progress --scanners vuln --exit-code 1 --severity HIGH,CRITICAL --format table ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Cleanup Local Images') {
            steps {
                script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                    sh "docker rmi ${IMAGE_NAME}:latest || true"
                }
            }
        }
    }

    post {
        failure {
            emailext body: """
                <h2>❌ Jenkins Pipeline Failed!</h2>
                <p><b>Job Name:</b> ${env.JOB_NAME}</p>
                <p><b>Build Number:</b> #${env.BUILD_NUMBER}</p>
                <p><b>Status:</b> <span style="color: red; font-weight: bold;">FAILED</span></p>
                <p>Check the Jenkins console output to debug the error: <a href="${env.BUILD_URL}">Console Output</a></p>
            """, 
            subject: "🚨 ${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Failed", 
            mimeType: 'text/html', 
            to: "zeyadmoustafa732@gmail.com"
        }
        
        success {
            emailext body: """
                <h2>✅ Jenkins Pipeline Successful!</h2>
                <p><b>Job Name:</b> ${env.JOB_NAME}</p>
                <p><b>Build Number:</b> #${env.BUILD_NUMBER}</p>
                <p><b>Status:</b> <span style="color: green; font-weight: bold;">SUCCESSFUL</span></p>
                <p>You can view the build details here: <a href="${env.BUILD_URL}">Build Link</a></p>
            """, 
            subject: "🎉 ${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Successful", 
            mimeType: 'text/html', 
            to: "zeyadmoustafa732@gmail.com"
        }      
    }
}
