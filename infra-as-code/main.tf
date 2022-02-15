#region S3
#Creates a S3 bucket
module "codepipeline-artifacts-bucket" {
  source          = "./modules/s3"
  ENV             = "prd"
  PROJECT_NAME    = "streaming-processing"
  RESOURCE_SUFFIX = "codepipeline-artifacts"
  AWS_TAGS        = "streaming-processing"
}

#Uploads the reference table to S3
resource "aws_s3_bucket_object" "reference-table" {
  key = "reference-table/upload-from-terraform/users_annual_income.csv"
  bucket = module.codepipeline-artifacts-bucket.id
  source = "../kda-utils/users_annual_income.csv"
  server_side_encryption = "AES256"
  etag = filemd5("../kda-utils/users_annual_income.csv")
}
#endregion