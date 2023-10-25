terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "jb-labs-test"
    key    = "ECS-prometheus"
    region = "eu-west-2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
