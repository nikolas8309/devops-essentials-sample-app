pipeline {
  agent any

  // triggers {
    // pollSCM('H/15 * * * *')
  // }

  environment{
      def ECR_NAME = '043260917987.dkr.ecr.us-east-2.amazonaws.com/experimental_site'
      def PROJECT = 'experimental_site'
      def VERSION = 'latest'
      
      def REGION = "us-east-2"
      // def SERVICE_NAME = "dw-web-panel"
      // def ECS_CLUSTER_SUFFIX = "-services-cluster"

      //auto populated, do not touch
      def IMAGE = "$ECR_NAME/$PROJECT:$VERSION"
      def ECRURL = "http://$ECR_NAME"
      
  }
  
  parameters {
    // ooleanParam(name: 'deployToDev', defaultValue: false, description: 'Deploy to dev?')
    booleanParam(name: 'deployToStg', defaultValue: false, description: 'Deploy to stg?')
    booleanParam(name: 'deployToPrd', defaultValue: false, description: 'Deploy to prd?')
  }
  
  stages {
    stage('PrintInfo') {
        steps {
            sh """
            echo "deployToStg=${params.deployToStg}"
            echo "deployToPrd=${params.deployToPrd}"
            """
        }
    } 
  
    stage('Build') {
      steps {
        sh """
            echo STEP!
        """
      }
    }        
    
    stage('Bake docker image') {
        steps{
            script{
                DCR_IMAGE = docker.build ("$IMAGE")
            }
        }
    }
    
   
    
    stage('Docker push'){
        steps{
            script{
                // login to ECR
                sh("eval \$(aws ecr get-login --no-include-email | sed 's|https://||')")

                // Push the Docker image to ECR
                docker.withRegistry(ECRURL){
                    docker.image(IMAGE).push()
                }
            }
        }
    }

    stage('DeployToStg') {
        when {
            environment name: 'deployToStg', value: 'true'
            beforeAgent true
        }
        steps {
            script{    
                environmentToDeploy='stg'
                ECS_CLUSTER="${environmentToDeploy}${ECS_CLUSTER_SUFFIX}"
            }
            ecsDeploy("$REGION","seirina","$ECS_CLUSTER","$SERVICE_NAME","$IMAGE",false,"300","5")
        }
    }
	
    stage('DeployToPrd') {
        when {
            environment name: 'deployToPrd', value: 'true'
            beforeAgent true
        }
        steps {
            script{    
                environmentToDeploy='prd'
                ECS_CLUSTER="${environmentToDeploy}${ECS_CLUSTER_SUFFIX}"
            }
            ecsDeploy("$REGION","seirina","$ECS_CLUSTER","$SERVICE_NAME","$IMAGE",false,"300","5")
        }
    }

  }
  
  post{
     always{
         //make sure that the Docker image is removed
         sh "docker rmi $IMAGE | true"
     }
  }
}
