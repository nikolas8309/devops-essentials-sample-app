pipeline {
  agent any

  // triggers {
    // pollSCM('H/15 * * * *')
  // }

  environment{
      def ECR_NAME = '043260917987.dkr.ecr.eu-west-2.amazonaws.com'
      def PROJECT = 'experimental_site'
      def VERSION = 'latest'
      
      def REGION = "eu-west-2"
      def ECS_CLUSTER_SUFFIX = "-cluster"

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
			sudo apt-get install -y jq

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
                sh("eval \$(aws2 ecr get-login --no-include-email --region eu-west-2 | sed 's|https://||')")

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
				SERVICE_NAME="stg"
            }
            ecsDeploy("$REGION","AKIAQUEUNHDR4ZHCL7SN","$ECS_CLUSTER","$SERVICE_NAME","$IMAGE",false,"300","5")
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
				SERVICE_NAME="prd"
            }
            ecsDeploy("$REGION","AKIAQUEUNHDR4ZHCL7SN","$ECS_CLUSTER","$SERVICE_NAME","$IMAGE",false,"300","5")
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
