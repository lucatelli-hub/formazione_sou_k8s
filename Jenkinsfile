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

                    if (env.TAG_NAME) {
                        env.IMAGE_TAG = env.TAG_NAME
                    }

                    else if (env.BRANCH_NAME == "main" || env.BRANCH_NAME == "master") {
                        env.IMAGE_TAG = "latest"
                    }

                    else if (env.BRANCH_NAME == "develop") {
                        def sha = sh(
                            script: "git rev-parse --short HEAD",
                            returnStdout: true
                        ).trim()

                        env.IMAGE_TAG = "develop-${sha}"
                    }

                    else {
                        env.IMAGE_TAG = "latest"
                    }

                    echo "Using tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(
                        "${IMAGE_NAME}:${IMAGE_TAG}",
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
                            "${IMAGE_NAME}:${IMAGE_TAG}"
                        ).push()
                    }
                }
            }
        }
    }
}
