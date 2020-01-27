#variable "AWS_REGION" {
#type = string
#}

#variable "VPC_CIDR" {
#type = string
#}

#variable "VPC_NAME" {
#type = string
#}

#variable "S3_BUCKET_TFSTATE" {
#type = string
#}

#variable "TENANT_NAME" {
#type = string
#}

terraform {
  backend "s3" {
}
}


######
# VPC
######

resource "aws_vpc" "vpc" {
  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = var.VPC_NAME
    Account_Name =  var.TENANT_NAME
  }
}

