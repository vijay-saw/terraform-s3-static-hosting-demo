terraform {
  backend "s3" {
    bucket = "vijay-terraform-bucket1"
    key    = "tffilestore/terraform.tfstate"
    region = "us-east-1"
  }
}
