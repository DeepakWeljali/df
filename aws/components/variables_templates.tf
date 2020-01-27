variable "AWS_REGION" {
type = string
default = "<AWS_REGION>"
}

variable "VPC_CIDR" {
type = string
default = "<VPC_CIDR>"
}

variable "VPC_NAME" {
type = string
default = "<VPC_NAME>"
}

variable "TENANT_NAME" {
type = string
default = "<TENANT_NAME>"
}

variable "PUBLIC_SUBNET_CIDR" {
type = list
default = <PUBLIC_SUBNET_CIDR>
}

variable "SDLC_ENVIRONMENT"{
default = "<SDLC_ENVIRONMENT>"
}

variable "PRIVATE_SUBNET_CIDR" {
type = list
default = <PRIVATE_SUBNET_CIDR>
}

variable "AMI_ID" {
default = "<AMI_ID>"
}

variable "INSTANCE_TYPE" {
default = "<INSTANCE_TYPE>"
}

variable "KEY_NAME" {
default = "<KEY_NAME>"
}

