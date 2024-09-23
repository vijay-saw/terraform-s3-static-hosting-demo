pipeline {
    agent any

    stages {
        stage('Clone GitHub Repository') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/vijay-saw/terraform-s3-static-hosting-demo'
            }
        }
        stage('Initialize Terraform') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'terraform init'
                        sh 'terraform plan'
                    }
                }
            }
        }
        stage('Apply Terraform Changes') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
        stage('Destroy Resources') {
            steps {
                script {
                    
                    def userInput = input(
                        id: 'userInput', 
                        message: 'Do you want to destroy the resources?',
                        parameters: [[$class: 'BooleanParameterDefinition', name: 'Destroy', defaultValue: false]]
                    )
                    if (userInput) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                            sh 'terraform destroy -auto-approve'
                        }
                    } else {
                        echo 'Destruction of resources was skipped.'
                    }
                }
            }
        }
    }
}
