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
  map_public_ip_on_launch = "true"

  tags = {
    Name = "terraform-public-subnet-1a"
  }
}

resource "aws_subnet" "terraform-public-subnet-1b" {
  vpc_id     = aws_vpc.terraform-VPC.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "terraform-public-subnet-1b"
  }
}


#Creating EC2 machine on private subnet 1a
# resource "aws_instance" "card-service" {
# ami           = "ami-0f5ee92e2d63afc18"
#  instance_type = "t2.micro"
#  availability_zone = aws_subnet.terraform-public-subnet-1a.id
#  key_name = aws_key_pair.terrafrom-keypair.id 
# associate_public_ip_address ="true"
#  vpc_security_group_ids = [aws_security_group.terraform-security-group.id]

#  tags = {
#    Name = "card-website"
#  }
#}


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



#Creating a security group for EC2
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
    Name = "terraform-security-group"
  }
}



#Creating a Route Table for Public subnets
resource "aws_route_table" "terraform-RT" {
  vpc_id = aws_vpc.terraform-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-IG.id
  }

  tags = {
    Name = "terraform-RT"
  }
}

#Associating Public subnets to Public Route Tables
resource "aws_route_table_association" "terraform-RT-association" {
  subnet_id      = aws_subnet.terraform-public-subnet-1a.id
  route_table_id = aws_route_table.terraform-RT.id
}

resource "aws_route_table_association" "terraform-RT-association1" {
  subnet_id      = aws_subnet.terraform-public-subnet-1b.id
  route_table_id = aws_route_table.terraform-RT.id
}



#Creating a Route Table for Private subnets
resource "aws_route_table" "terrafrom-private-RT" {
  vpc_id = aws_vpc.terraform-VPC.id

  tags = {
    Name = "terraform-private-RT"
  }
}

#Associating Private subnets to Private Route Tables
resource "aws_route_table_association" "terraform-private-RT-association" {
  subnet_id      = aws_subnet.terraform-private-subnet-1a.id
  route_table_id = aws_route_table.terrafrom-private-RT.id
}

resource "aws_route_table_association" "terraform-private-RT-association1" {
  subnet_id      = aws_subnet.terraform-private-subnet-1b.id
  route_table_id = aws_route_table.terrafrom-private-RT.id
}



#Creating the Launch Template for ASG
resource "aws_launch_template" "terraform-LT" {
  name = "terraform-LT"
  instance_type = "t2.micro"
  image_id = "ami-0f5ee92e2d63afc18"
  key_name = aws_key_pair.terrafrom-keypair.id
   
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = true
  }

#placement {
#  availability_zone = ap-south-1a
#}

  vpc_security_group_ids = [aws_security_group.terraform-security-group.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Terraform-ASG-Project"
    }
  }

  user_data = filebase64("Instance-userdata.sh")
}



#Creating the Auto Scaling Group(ASG)
resource "aws_autoscaling_group" "terraform-ASG" {
  #availability_zones = [ap-south-1a, ap-south-1b]
  vpc_zone_identifier = [aws_subnet.terraform-public-subnet-1a.id, aws_subnet.terraform-public-subnet-1b.id]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  target_group_arns = [aws_lb_target_group.terraform-TG.arn]

  launch_template {
    id      = aws_launch_template.terraform-LT.id
    version = "$Latest"
  }
}


#Creating the Load Balancer Target group with ASG
resource "aws_lb_target_group" "terraform-TG" {
  name     = "terraform-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform-VPC.id
}



#Creating Load balancer Listerner with ASG
resource "aws_lb_listener" "terraform-listerner" {
  load_balancer_arn = aws_lb.terraform-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-TG.arn
  }
}



#Creating Load Balancer
resource "aws_lb" "terraform-loadbalancer" {
  name               = "terraform-loadbalancer"
  internal           = "false"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform-security-group.id]
  subnets            = [aws_subnet.terraform-public-subnet-1a.id, aws_subnet.terraform-public-subnet-1b.id]

  tags = {
    Environment = "Project"
  }
}
