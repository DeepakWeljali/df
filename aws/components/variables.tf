variable "AWS_REGION" {
type = string
default = "us-east-1"
}

variable "VPC_CIDR" {
type = string
default = "10.0.0.0/16"
}

variable "VPC_NAME" {
type = string
default = "12-df_VPC"
}

variable "TENANT_NAME" {
type = string
default = "12-df"
}

variable "PUBLIC_SUBNET_CIDR" {
type = list
default = ["10.0.1.0/28"]
}


variable "PRIVATE_SUBNET_CIDR" {
type = list
default = ["10.0.3.0/28"]
}

variable "AMI_ID" {
default = "ami-4fffc834"
}

variable "INSTANCE_TYPE" {
default = "t2.micro"
}

variable "KEY_NAME" {
default = "df"
}

