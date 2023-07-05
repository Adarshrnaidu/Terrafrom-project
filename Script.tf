terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


  # Creating s3 bucket for the backup
  backend "s3" {
    bucket = "terraform-project-script-backend-bucket"
    key    = "Terrafrom-script.tf"
    region = "ap-south-1"
 }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


#Creating VPC
resource "aws_vpc" "terraform-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Terraform-VPC"
  }
}

#Creating private subnets
resource "aws_subnet" "terraform-private-subnet-1a" {
  vpc_id     = aws_vpc.terraform-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "terrafrom-private-subnet-1a"
  }
}

resource "aws_subnet" "terraform-private-subnet-1b" {
  vpc_id     = aws_vpc.terraform-VPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform-private-subnet-1b"
  }
}


#Creating public subnets
resource "aws_subnet" "terraform-public-subnet-1a" {
  vpc_id     = aws_vpc.terraform-VPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform-public-subnet-1a"
  }
}

resource "aws_subnet" "terraform-public-subnet-1b" {
  vpc_id     = aws_vpc.terraform-VPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform-public-subnet-1b"
  }
}