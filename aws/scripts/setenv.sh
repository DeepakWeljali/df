#!/bin/bash
#
# This should be included by each script to DRY things up.
#
#SDLC_ENVIRONMENT=prod
echo ' -- Utility functions and shared variables included.'

###################
# Global settings
# Functions
#function fatal(){
#  echo "FATAL: $1"
#  exit 1
#}

#SDLC env will be production

function set_environment(){
  #case "$SDLC_ENVIRONMENT" in
  #  "stg"|"prod")
      [ -z "$AWS_REGION" ] && AWS_REGION='us-east-1'
      AWS_REGION_NAME='UsEast1'
      TENANT_NAME="12-df"
      AWS_ACCOUNT_NUMBER="6542456899"
      VPC_CIDR="10.0.0.0/16"
      VPC_NAME="${TENANT_NAME}_VPC"
      S3_BUCKET_TFSTATE="${TENANT_NAME}-tfstate"
      PUBLIC_SUBNET_CIDR='["10.0.1.0/28"]'
      PRIVATE_SUBNET_CIDR='["10.0.3.0/28"]'
      INSTANCE_TYPE="t2.micro"
      AMI_ID="ami-4fffc834"
      KEY_NAME="df"
#      ;;
#    *)
#      [ -z "$AWS_REGION" ] && AWS_REGION='us-east-1'
#      AWS_REGION_NAME='UsEast1'
#      TENANT_NAME="12-df"
#      AWS_ACCOUNT_NUMBER="6542456899"
#     VPC_CIDR="10.0.0.0/16"
#     VPC_NAME="${TENANT_NAME}_VPC"
#     S3_BUCKET_TFSTATE="${TENANT_NAME}-tfstate"
#      PUBLIC_SUBNET_CIDR='["10.0.1.0/28"]'
#      PRIVATE_SUBNET_CIDR='["10.0.3.0/28"]'
#      INSTANCE_TYPE="t2.micro"
#      AMI_ID="ami-062f7200baf2fa504"
#      KEY_NAME="df"
#      ;;
#  esac
}

echo "Calling set environment"
set_environment

COMPONENT_PATH="aws/components"
cp $COMPONENT_PATH/variables_templates.tf $COMPONENT_PATH/variables.tf

sed -i  -e "s#<AWS_REGION>#${AWS_REGION}#" \
    -e "s#<VPC_CIDR>#$VPC_CIDR#" \
    -e "s#<VPC_NAME>#$VPC_NAME#" \
    -e "s#<TENANT_NAME>#$TENANT_NAME#" \
    -e "s#<PUBLIC_SUBNET_CIDR>#$PUBLIC_SUBNET_CIDR#" \
    -e "s#<SDLC_ENVIRONMENT>#$SDLC_ENVIRONMENT#" \
    -e "s#<PRIVATE_SUBNET_CIDR>#$PRIVATE_SUBNET_CIDR#" \
    -e "s#<AMI_ID>#$AMI_ID#" \
    -e "s#<INSTANCE_TYPE>#$INSTANCE_TYPE#" \
    -e "s#<KEY_NAME>#$KEY_NAME#" $COMPONENT_PATH/variables.tf


cat <<EOF_set_environment
 Environment settings:
      TENANT_NAME=$TENANT_NAME
      ACCOUNT_NUMBER=$ACCOUNT_NUMBER
      AWS_REGION=$AWS_REGION
      S3_BUCKET_TFSTATE=$S3_BUCKET_TFSTATE
      VPC_CIDR=$VPC_CIDR
      VPC_NAME=$VPC_NAME
      PUBLIC_SUBNET_CIDR=$PUBLIC_SUBNET_CIDR
      AMI_ID=$AMI_ID
      KEY_NAME=$KEY_NAME
      INSTANCE_TYPE=$INSTANCE_TYPE
EOF_set_environment
