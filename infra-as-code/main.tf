locals {
  PROJECT_NAME   = "streaming-processing"
  ENV            = "dev"
}

data "aws_region" "current" {}

#region S3
#Creates a S3 bucket
module "codepipeline-artifacts-bucket" {
  source          = "./modules/s3"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "codepipeline-artifacts"
}

#Uploads the reference table to S3
resource "aws_s3_object" "reference-table" {
  key = "reference-table/upload-from-terraform/clients_annual_income.csv"
  bucket = module.codepipeline-artifacts-bucket.id
  source = "../utils/clients_annual_income.csv"
  server_side_encryption = "AES256"
  etag = filemd5("../utils/clients_annual_income.csv")
}
#endregion

#region lamnda-layer
module "lambda-layer" {
  source                = "./modules/lambda-layer"
  ENV                   = local.ENV
  PROJECT_NAME          = local.PROJECT_NAME
  RESOURCE_SUFFIX       = "lambda-layer"
  BUILDER_SCRIPT_PATH   = "../lambdas/layer-builder/build.sh"
  REQUIREMENTS_PATH     = "requirements.txt"
  PACKAGE_OUTPUT_NAME   = "python_dependencies"
}
#endregion

#region lambda
module "lambda-data-producer" {
  source          = "./modules/lambda"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "data-producer"
  LAMBDA_LAYER    = [module.lambda-layer.arn]
  LAMBDA_SETTINGS = {
    "description" = "Data producer lambda"
    "handler"     = "data_producer.lambda_handler"
    "runtime"     = "python3.8"
    "timeout"     = 600
    "memory_size" = 512
    "filename"    = "lambdas/"
  }
  LAMBDA_ENVIRONMENT_VARIABLES = {
    "CSV_PATH_LOCATION" = "${aws_s3_object.reference-table.bucket}/${aws_s3_object.reference-table.key}"
    "SNS_TOPIC_ARN"     = module.sns-data-producer.arn
    "NUMBER_OF_THREADS" = 10
    "REGION"        = data.aws_region.current.name
  }
}

#region SNS
module "sns-data-producer" {
  source          = "./modules/sns/topic"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "data-producer"
}