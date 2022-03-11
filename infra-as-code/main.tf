locals {
  PROJECT_NAME   = "streaming-processing"
  ENV            = "prd"
  TAGS           = "streaming-processing"
}

#region S3
#Creates a S3 bucket
module "codepipeline-artifacts-bucket" {
  source          = "./modules/s3"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "codepipeline-artifacts"
  AWS_TAGS        = local.TAGS
}

#Uploads the reference table to S3
resource "aws_s3_bucket_object" "reference-table" {
  key = "reference-table/upload-from-terraform/clients_annual_income.csv"
  bucket = module.codepipeline-artifacts-bucket.id
  source = "../utils/clients_annual_income.csv"
  server_side_encryption = "AES256"
  etag = filemd5("../utils/clients_annual_income.csv")
}
#endregion