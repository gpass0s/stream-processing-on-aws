terraform {
  backend "s3" {
    bucket      = "gpass0s-aws-cicd-pipeline"
    key         = "gpass0s-aws-cicd-pipeline.tfstate"
    region      = "us-east-1"
    encrypt     = true
    role_arn    = "arn:aws:iam::777455183230:role/gpass0s-terraform-role"
  }
}
