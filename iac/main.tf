terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  #profile = "superhero"
}

terraform {
  backend "s3" {
    bucket = "8amcloudbinary"
    key    = "dev/terraform.state"
    region = "us-east-1"
    #profile = "superhero"
  }
}


# VPC
resource "aws_vpc" "cloudbinary" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name      = "cloudbinary_VPC"
    CreatedBy = "iac - terraform"
  }
}

# Subnet - Public-1 
resource "aws_subnet" "cloudbinary_public_subnet_1" {
  vpc_id                  = aws_vpc.cloudbinary.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name      = "cloudbinary_public_subnet_1"
    CreatedBy = "iac - terraform"
  }

}
# Subnet - Public-2
resource "aws_subnet" "cloudbinary_public_subnet_2" {
  vpc_id                  = aws_vpc.cloudbinary.id
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name      = "cloudbinary_public_subnet_2"
    CreatedBy = "iac - terraform"
  }

}
# Subnet - private-1 
resource "aws_subnet" "cloudbinary_private_subnet_1" {
  vpc_id            = aws_vpc.cloudbinary.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name      = "cloudbinary_private_subnet_1"
    CreatedBy = "iac - terraform"
  }

}
# Subnet - private-2 
resource "aws_subnet" "cloudbinary_private_subnet_2" {
  vpc_id            = aws_vpc.cloudbinary.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name      = "cloudbinary_private_subnet_2"
    CreatedBy = "iac - terraform"
  }

}

# RTB - Public-1
resource "aws_route_table" "cloudbinary_public_rtb" {
  vpc_id = aws_vpc.cloudbinary.id

  tags = {
    Name      = "cloudbinary_public_rtb"
    CreatedBy = "iac - terraform"
  }
}

# RTB - Private-1
resource "aws_route_table" "cloudbinary_private_rtb" {
  vpc_id = aws_vpc.cloudbinary.id

  tags = {
    Name      = "cloudbinary_private_rtb"
    CreatedBy = "iac - terraform"
  }
}

# IGW 
resource "aws_internet_gateway" "cloudbinary_igw" {
  vpc_id = aws_vpc.cloudbinary.id

  tags = {
    Name      = "cloudbinary_igw"
    CreatedBy = "iac - terraform"
  }

}

# Create Routing to Public-RTB From IGW
resource "aws_route" "cloudbinary_rtb_igw" {
  route_table_id         = aws_route_table.cloudbinary_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloudbinary_igw.id

}

# Subnet Association with Public Route Table
resource "aws_route_table_association" "cloudbinary_public_subnet_1_association" {
  subnet_id      = aws_subnet.cloudbinary_public_subnet_1.id
  route_table_id = aws_route_table.cloudbinary_public_rtb.id
}
# Subnet Association with Public Route Table
resource "aws_route_table_association" "cloudbinary_public_subnet_2_association" {
  subnet_id      = aws_subnet.cloudbinary_public_subnet_2.id
  route_table_id = aws_route_table.cloudbinary_public_rtb.id
}

# Subnet Association with Private Route Table
resource "aws_route_table_association" "cloudbinary_private_subnet_1_association" {
  subnet_id      = aws_subnet.cloudbinary_private_subnet_1.id
  route_table_id = aws_route_table.cloudbinary_private_rtb.id
}
# Subnet Association with Private Route Table
resource "aws_route_table_association" "cloudbinary_private_subnet_2_association" {
  subnet_id      = aws_subnet.cloudbinary_private_subnet_2.id
  route_table_id = aws_route_table.cloudbinary_private_rtb.id
}

# EIP 
resource "aws_eip" "cloudbinary_eip" {
  vpc = true
}

# NAT Gateway & Attach EIP to NAT GATEWAY
resource "aws_nat_gateway" "cloudbinary_natgw" {
  allocation_id = aws_eip.cloudbinary_eip.id
  subnet_id     = aws_subnet.cloudbinary_public_subnet_1.id

  tags = {
    Name      = "cloudbinary_natgw"
    CreatedBy = "iac - terraform"
  }
}

# Allow  Nat Gateway To Private Route Table
resource "aws_route" "cloudbinary_allow_natgw" {
  route_table_id         = aws_route_table.cloudbinary_private_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.cloudbinary_natgw.id

}

# NACL 
resource "aws_network_acl" "cloudbinary_nacl" {
  vpc_id     = aws_vpc.cloudbinary.id
  subnet_ids = [aws_subnet.cloudbinary_public_subnet_1.id, aws_subnet.cloudbinary_public_subnet_2.id, aws_subnet.cloudbinary_private_subnet_1.id, aws_subnet.cloudbinary_private_subnet_2.id]

  # ingress / inbound
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  # egress / outbound
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name      = "cloudbinary_nacl"
    CreatedBy = "IAC - Terraform"
  }

}

# SG For Bastion
resource "aws_security_group" "cloudbinary_sg_bastion" {
  vpc_id      = aws_vpc.cloudbinary.id
  name        = "sg_bastion"
  description = "Allow SSH And RDP"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudbinary_sg_bastion"
    Description = "Allow SSH and RDP"
    CreatedBy   = "IAC - Terraform"
  }

}

# SG For WebServer
resource "aws_security_group" "cloudbinary_sg_web" {
  vpc_id      = aws_vpc.cloudbinary.id
  name        = "sg_web"
  description = "Allow SSH - RDP - HTTP - DB "

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudbinary_sg_web"
    Description = "Allow SSH - RDP - HTTP - DB - TOMCAT"
    CreatedBy   = "IAC - Terraform"
  }

}

/* resource "aws_instance" "cloudbinary_bastion" {
  ami                    = "ami-02c4808b9f729b235"
  instance_type          = "t2.micro"
  key_name               = "aws-kesav"
  subnet_id              = aws_subnet.cloudbinary_public_subnet_1.id
  vpc_security_group_ids = ["${aws_security_group.cloudbinary_sg_bastion.id}"]

  tags = {
    Name      = "cloudbinary_bastion"
    CreatedBy = "IAC - Terraform"
    OSType    = "Windows"
  }
} */

# EC2 Instance in Private Subnet
resource "aws_instance" "cloudbinary_web" {
  ami                    = "ami-0b680987f5a40c9a1"
  instance_type          = "t2.micro"
  key_name               = "aws8amnv"
  subnet_id              = aws_subnet.cloudbinary_public_subnet_1.id
  vpc_security_group_ids = ["${aws_security_group.cloudbinary_sg_web.id}"]
  #user_data              = file("web.sh")

  tags = {
    Name      = "cloudbinary_web"
    CreatedBy = "IAC - Terraform"
    OSType    = "Linux - Ubuntu 20.04"
  }
}