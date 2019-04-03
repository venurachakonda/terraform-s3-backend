provider "aws" {
  region = "us-west-2"
}

# Resource to create S3 bucket for storing remote state file
resource "aws_s3_bucket" "s3-terraform-state-storage" {
    bucket = "s3-terraform-state-storage"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    tags {
      Name = "Terraform S3 Remote State Store"
    }
}

# Resource to create Dynamodb table for locking the state file
resource "aws_dynamodb_table" "terraform-state-lock" {
  name = "terraform-state-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "Terraform State Lock Table"
  }
}


terraform {
  backend "s3" {
    encrypt = true                             //encrypts data
    bucket = "s3-terraform-state-storage"      //name of s3 bucket
    region = "us-west-2"                       //region
    key = remote/terraform.tfstate             //name of tfstate file
    dynamo_table = "terraform-state-lock"      //dynamoDB table for state locking
  }
}
