pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: "10"))
    }
    parameters {
        string(name: 'awsRegion', defaultValue: 'us-west-2', description: 'Region')
        string(name: 'taskDefinition', defaultValue: 'frontend', description: 'The name of the task definition')
        string(name: 'service', defaultValue: 'frontend-svd', description: 'The name of the service')
        string(name: 'cluster', defaultValue: 'test', description: 'The name of the cluster')
        string(name: 'taskDefinitionFile', defaultValue: 'task-definition.json', description: 'The name of the task definition file')
        string(name: 'dockerImage', defaultValue: 'web', description: 'The name of the Docker image')
        string(name: 'dockerTag', defaultValue: 'latest', description: 'The tag of the Docker image')
        string(name: 'ecrRepository', defaultValue: '240633844458.dkr.ecr.us-west-2.amazonaws.com', description: 'The name of the ECR repository')
    }
    stages {
        stage('Push Docker Image') {
            steps {
                script {
                    def loginCommand = "aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${params.ecrRepository}"
                    sh loginCommand
                    def buildimage = "docker build  -t ${dockerImage}:${dockerTag} ."
                    sh buildimage
                    def tagCommand = "docker tag ${params.dockerImage}:${params.dockerTag} ${params.ecrRepository}/${params.dockerImage}:${params.dockerTag}"
                    sh tagCommand
                    def pushCommand = "docker push ${params.ecrRepository}/${params.dockerImage}:${params.dockerTag}"
                    sh pushCommand
                }
            }
        }
        stage('Create Task Definition') {
            steps {
                script {
                    def createTaskDefinitionCommand = "aws ecs register-task-definition --family ${taskDefinition}  --cli-input-json --region ${awsRegion} file://aws/${params.taskDefinitionFile}"
                    sh createTaskDefinitionCommand
                }
            }
        }
        stage('Update ECS Service') {
            steps {
                script {
                    def updateCommand = "aws ecs update-service --cluster ${params.cluster} --service ${params.service} --region ${awsRegion} --task-definition ${params.taskDefinition}"
                    sh updateCommand
                }
            }
        }

    }
}
