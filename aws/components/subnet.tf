#variable "AWS_REGION" {
#type = string
#}

#variable "VPC_NAME" {
#}

#variable "PUBLIC_SUBNET_CIDR" {
#type = list
#}

#variable "TENANT_NAME" {
#}

#variable "SDLC_ENVIRONMENT"{
#}

#variable "PRIVATE_SUBNET_CIDR" {
#type = list
#}

terraform {
  backend "s3" {
}
}

#Getting VPC ID by VPC name
data "aws_vpc" "myvpc" {
  tags = {
    Name = var.VPC_NAME
  }
}

#List of Availability Zone
data "aws_availability_zones" "available" {
  state = "available"
}

#Public Subnet
resource "aws_subnet" "public_subnet" {
    count = length(var.PUBLIC_SUBNET_CIDR) 
    vpc_id =  data.aws_vpc.myvpc.id
#    cidr_block = var.PUBLIC_SUBNET_CIDR
    cidr_block = element(var.PUBLIC_SUBNET_CIDR, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"public_subnet",count.index])
    }
}

#Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = data.aws_vpc.myvpc.id
    tags = {
        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"internet_gateway"])
    }
}

#Route Table
resource "aws_route_table" "public_route_table" {
    vpc_id = data.aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"route_table"])
    }
}

#Route table association for public subnet
resource "aws_route_table_association" "public_route_table_association" {
    count = length(var.PUBLIC_SUBNET_CIDR)
    subnet_id = element(aws_subnet.public_subnet.*.id,count.index)
    route_table_id = aws_route_table.public_route_table.id
}

#Private Subnet
resource "aws_subnet" "private_subnet" {
    count = length(var.PRIVATE_SUBNET_CIDR)
    vpc_id =  data.aws_vpc.myvpc.id
#    cidr_block = var.PRIVATE_SUBNET_CIDR
    cidr_block = element(var.PRIVATE_SUBNET_CIDR, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"private_subnet",count.index])
    }
}

#Elastic IP
resource "aws_eip" "nat_ip" {
    count = length(var.PUBLIC_SUBNET_CIDR)
    vpc = true
}

#NAT Gateway
#resource "aws_nat_gateway" "nat_gateway" {
#    count = length(var.PUBLIC_SUBNET_CIDR)
#    allocation_id = element(aws_eip.nat_ip.*.id, count.index)
#    subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
#    tags ={
#        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"nat_gateway",count.index])
#    }
#}

#NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = element(aws_eip.nat_ip.*.id, 0 )
    subnet_id = element(aws_subnet.public_subnet.*.id, 0 )
    tags ={
        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"nat_gateway"])
    }
}



#Route Table
resource "aws_route_table" "private_route_table" {
    count = length(var.PRIVATE_SUBNET_CIDR)
    vpc_id =  data.aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id,count.index)
    }
    tags ={
        Name = join("_", [var.TENANT_NAME,var.SDLC_ENVIRONMENT,"private_route_table",count.index])
    }
}

#Route table association for private subnet
resource "aws_route_table_association" "private_route_table_association" {
    count = length(var.PRIVATE_SUBNET_CIDR)
    subnet_id = element(aws_subnet.private_subnet.*.id,count.index)
    route_table_id = element(aws_route_table.private_route_table.*.id,count.index)
}
