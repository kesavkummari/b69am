# Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  profile = "default"
}
# AWS Resources 
resource "aws_instance" "dev" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name      = "dev"
    CreatedBy = "Terraform"
  }
}
# Outputs
output "public_ip" {
  value = aws_instance.dev.public_ip
}