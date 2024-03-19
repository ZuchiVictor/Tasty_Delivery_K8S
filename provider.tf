terraform {
  backend "s3" {
    bucket = "terraform-fiap-rds" # example: terraform-tfstates
    key    = "tastyDeliveryEcs/terraform.tfstate"
    region = "us-east-1" # example: us-east-1 (região escolhida na criação do bucket)
  }
}

provider "aws" {
  profile = "default" # trocar pelo profile que tiver, ou retirar se utilizar o aws configure sem um profile
  region  = var.regionDefault

  default_tags {
    tags = var.tags
  }
}