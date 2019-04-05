provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "remote-state-storage" //name of s3 bucket
    region = "us-east-1"
    key = "iac/terraform.tfstate"
    dynamodb_table = "remote-state-lock"
  }
}
