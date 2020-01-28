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

