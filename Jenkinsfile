pipeline {
    agent any

    environment {
        IMAGE_NAME = "federicolucat6/flask-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Determine Tag') {
            steps {
                script {

                    def gitTag = sh(
                        script: "git describe --tags --exact-match HEAD || true",
                        returnStdout: true
                    ).trim()

                    def gitBranch = env.GIT_BRANCH ?: ""

                    echo "Detected GIT_BRANCH: ${gitBranch}"
                    echo "Detected Git Tag: ${gitTag}"

                    if (gitTag) {
                        env.IMAGE_TAG = gitTag
                    }

                    else if (gitBranch.contains("main") || gitBranch.contains("master")) {
                        env.IMAGE_TAG = "latest"
                    }

                    else if (gitBranch.contains("develop")) {

                        def sha = sh(
                            script: "git rev-parse --short HEAD",
                            returnStdout: true
                        ).trim()

                        env.IMAGE_TAG = "develop-${sha}"
                    }

                    else {
                        env.IMAGE_TAG = "latest"
                    }

                    echo "Final Docker Tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(
                        "${IMAGE_NAME}:${env.IMAGE_TAG}",
                        "./app"
                    )
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-creds') {
                        docker.image(
                            "${IMAGE_NAME}:${env.IMAGE_TAG}"
                        ).push()
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker rmi ${IMAGE_NAME}:${env.IMAGE_TAG} || true"
            }
        }
    }

    post {
        success {
            echo "Build completed successfully"
        }

        failure {
            echo "Build failed"
        }
    }
}
