terraform {
  backend "s3" {
    bucket      = "gpass0s-aws-cicd-pipeline"
    key         = "terraform-assests/terraform.tfstate"
    region      = "us-east-1"
    encrypt     = true
  }
}