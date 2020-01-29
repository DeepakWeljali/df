#Infra Deployment
#!/bin/bash
set -e
echo "### Infra deployment for the provided sdlc environment"


#SDLC_ENVIRONMENT=$1
BRANCH=$1
ACT=$2


if [[ "$#" -lt 2 ]]; then
  echo "Exiting: Pipeline parameters are missing. Cannot execute the pipeline"
  exit 1
fi

#Script Directory
SCRIPT_PATH='aws/scripts'

#Component Directory
COMPONENT_PATH="aws/components"

#Temp Terraform Directory
TERRAFORM_TEMPLATE="aws/terraform_template"

cat <<EOF_code_params
#SDLC_ENVIRONMENT=$SDLC_ENVIRONMENT
BRANCH=$BRANCH
EOF_code_params

# Check if we have the ENV script and execute it
SETENV_SCRIPT="${SCRIPT_PATH}/setenv.sh"
if [ ! -f "${SETENV_SCRIPT}" ]; then
  echo "FATAL: ${SETENV_SCRIPT} not found. Unable to include shared functions."
  echo "FATAL: ${SETENV_SCRIPT} not found. Unable to include shared functions."
  exit 1
fi
. ${SETENV_SCRIPT}

echo "Creating S3 bucket for TF state if not already available"
if [[ ! $(aws s3 ls | grep ${S3_BUCKET_TFSTATE}) ]]; then
  echo "Creating S3 bucket"
  aws s3 mb s3://${S3_BUCKET_TFSTATE} --region ${AWS_REGION}
else
  echo "S3 Bucket is already existing"
fi

if [ "$ACT" = "create" ]; then
    echo "Infrastructure creation in progress"
    component_list=("vpc" "subnet" "matillion" "thoughtspot")

    for component in ${component_list[@]}
    do
      mkdir ${TERRAFORM_TEMPLATE}
      cp ${COMPONENT_PATH}/${component}.tf ${TERRAFORM_TEMPLATE}/
      cp ${COMPONENT_PATH}/provider.tf ${TERRAFORM_TEMPLATE}/
      cp ${COMPONENT_PATH}/variables.tf ${TERRAFORM_TEMPLATE}/
      cd ${TERRAFORM_TEMPLATE}
      terraform init \
          -backend-config="bucket=$S3_BUCKET_TFSTATE" \
          -backend-config="key=${component}.state" \
          -backend-config="region=$AWS_REGION" 
      terraform apply -auto-approve
      cd ../../
      #terraform plan ${TERRAFORM_TEMPLATE} 
      rm -rf ${TERRAFORM_TEMPLATE}
    done
elif [ "$ACT" = "delete" ]; then
    echo "Delete in progress"
    component_list=("matillion" "thoughtspot" "subnet" "vpc")

    for component in ${component_list[@]}
    do
       mkdir ${TERRAFORM_TEMPLATE}
       cp ${COMPONENT_PATH}/${component}.tf ${TERRAFORM_TEMPLATE}/
       cp ${COMPONENT_PATH}/provider.tf ${TERRAFORM_TEMPLATE}/
       cp ${COMPONENT_PATH}/variables.tf ${TERRAFORM_TEMPLATE}/
       cd ${TERRAFORM_TEMPLATE}
       terraform init \
          -backend-config="bucket=$S3_BUCKET_TFSTATE" \
          -backend-config="key=${component}.state" \
          -backend-config="region=$AWS_REGION"
       terraform destroy -auto-approve
       cd ../../
       #terraform plan ${TERRAFORM_TEMPLATE}
       rm -rf ${TERRAFORM_TEMPLATE}
    done
else
    echo "Invalid action paramater"
    exit 1
fi
