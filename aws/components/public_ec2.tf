variable "INGRESS_PORT" {
type = list
default = ["22","80","8080"]
}

variable "INGRESS_CIDR" {
type = list
default = ["103.6.33.5/32","103.6.33.6/32"]
}

variable "EGRESS_CIDR" {
type = list
default = ["0.0.0.0/0"]
}

variable "EGRESS_PORT" {
default = "0"
}

variable "EGRESS_PROTOCOL" {
default = "-1"
}


#Getting VPC ID by VPC name
data "aws_vpc" "vpc" {
  tags = {
    Name = var.VPC_NAME
  }
}

#Getting public subnet using tags
data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Name = "*public*"
  }
}

terraform {
  backend "s3" {
}
}

#Security Group
resource "aws_security_group" "public_ec2_sg" {
  name = "public security group" 
  vpc_id = data.aws_vpc.vpc.id
  egress {
    from_port = var.EGRESS_PORT
    to_port   = var.EGRESS_PORT
    protocol  = var.EGRESS_PROTOCOL
    cidr_blocks = var.EGRESS_CIDR
  }
  dynamic "ingress" {
    for_each = var.INGRESS_PORT
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = var.INGRESS_CIDR
    }
  }
    tags = {
         Name = join("_", [var.TENANT_NAME,"public_sg"])
    }

}

#Public Instance
resource "aws_instance" "public_ec2_instance" {
    ami = var.AMI_ID
    instance_type = var.INSTANCE_TYPE
    key_name = var.KEY_NAME
    vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
    subnet_id = tolist(data.aws_subnet_ids.subnets.ids)[0]
    associate_public_ip_address = true
    source_dest_check = false
    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
        sudo yum install java-1.8.0 -y
        sudo yum install jenkins -y
        sudo service jenkins start
        sudo amazon-linux-extras install ansible2
        sudo yum install maven -y
        EOF

    tags = {
         Name = join("_", [var.TENANT_NAME,"public_instance"])
    }
}

#Elastic IP for public instance
resource "aws_eip" "elastic_ip_ec2" {
    instance = aws_instance.public_ec2_instance.id
    vpc = true
}
