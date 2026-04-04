terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "local" {
    path = "bootstrap.tfstate"
  }
}

provider "aws" {
  region = "eu-central-1"
}
