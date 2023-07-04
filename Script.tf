terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Creating s3 buvket for the backup
  backend "s3" {
    bucket = "Terrafrom"
    key    = "Terrafrom-script.tf"
    region = "ap-south-1"
 }

}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


#Creating VPC


