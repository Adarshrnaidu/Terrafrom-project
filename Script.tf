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
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "terrafrom-private-subnet-1a"
  }
}

resource "aws_subnet" "terraform-private-subnet-1b" {
  vpc_id     = aws_vpc.terraform-VPC.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform-private-subnet-1b"
  }
}


#Creating public subnets
resource "aws_subnet" "terraform-public-subnet-1a" {
  vpc_id     = aws_vpc.terraform-VPC.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "terraform-public-subnet-1a"
  }
}

resource "aws_subnet" "terraform-public-subnet-1b" {
  vpc_id     = aws_vpc.terraform-VPC.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "terraform-public-subnet-1b"
  }
}


#Creating EC2 machine on private subnet 1a
resource "aws_instance" "card-service" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  availability_zone = aws_subnet.terraform-public-subnet-1a.id
  key_name = aws_key_pair.terrafrom-keypair.id 
  associate_public_ip_address ="true"
  vpc_security_group_ids = [aws_security_group.terraform-security-group.id]

  tags = {
    Name = "card-website"
  }
}


#Creating keypair
resource "aws_key_pair" "terrafrom-keypair" {
  key_name   = "terraform-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvdRwwK4+Dr7pScPXcHQpviHpGOwmqhy9QG8ewxS9s2EMhlqhy7dh1wv+fOsx+5VtP1IVMGuJEfhflWZmi5dtSilhwLZn8nxJszL++YsYVT0kAfhD7r/wNPfga5atJhjwNP3SY4N1ArmG3evmX+xc748i1aKKrZyWwwY4fKHj4hvWbZzXxVMk5XsceprOVzDcbqhASmEoJ+pT/uWacOXLdj7Kb2TkJoanIXqIty51tvzutj7rmnL8PXXBDNIEX3qyyrwhd6Y7Q7QU2c2cQ+BwCl/3R7B5o4S2lKGE+DlbaAZvJIb/DfrJRiECHJufpjk3nNZBOC5sQDbT+NYzjgv6Gmnia7KPy02DNz/FZZSBpyzafdm9saSbm58yBa/uQJr/pQfMlzOV1II0O5ZA04j/210FOQb8YnpGylP3PWGzbI8Wn3oG+lJ6YJM/F1D+s98d/TKn/R3kab+KyobsDP8n+jPZjGi3Ua8eAp5L7T3rssPDgHHzZkb6UTO4HzclBtyU= Adars@DESKTOP-7D8DJ7U"
}


#Creating Internet gateway
resource "aws_internet_gateway" "terraform-IG" {
  vpc_id = aws_vpc.terraform-VPC.id

  tags = {
    Name = "Terraform-IG"
  }
}


#Creating a swcurity group for EC2
resource "aws_security_group" "terraform-security-group" {
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.terraform-VPC.id

  ingress {
    description      = "inbound-rule"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "inbound-rule1"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terrafrom-security-group"
  }
}


#Creating a Route Table
resource "aws_route_table" "terrafrom-RT" {
  vpc_id = aws_vpc.terraform-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-IG.id
  }

  tags = {
    Name = "terraform-RT"
  }
}


#Associating Public subnets to Route Tables
resource "aws_route_table_association" "terraform-RT-association" {
  subnet_id      = aws_subnet.terraform-public-subnet-1a.id
  route_table_id = aws_route_table.terrafrom-RT.id
}

resource "aws_route_table_association" "terraform-RT-association1" {
  subnet_id      = aws_subnet.terraform-public-subnet-1b.id
  route_table_id = aws_route_table.terrafrom-RT.id
}

