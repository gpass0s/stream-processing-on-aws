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
  source = "../lambdas/clients_annual_income.csv"
  server_side_encryption = "AES256"
  etag = filemd5("../lambdas/clients_annual_income.csv")
}
#endregion

#region lamnda-layer
module "lambda-layer" {
  source                = "./modules/lambda-layer"
  ENV                   = local.ENV
  PROJECT_NAME          = local.PROJECT_NAME
  RESOURCE_SUFFIX       = "lambda-layer"
  BUILDER_SCRIPT_PATH   = "../utils/layer-builder/build.sh"
  REQUIREMENTS_PATH     = "requirements.txt"
  PACKAGE_OUTPUT_NAME   = "lambda-layer"
}
#endregion

#region lambda
module "lambda-event-producer" {
  source          = "./modules/lambda"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "event-producer"
  LAMBDA_LAYER    = [module.lambda-layer.arn]
  LAMBDA_SETTINGS = {
    "description"         = "This function is a data producer that reproduces up to NUMBER_THREADS access simultaneously to the data pipeline"
    "handler"             = "event_producer.lambda_handler"
    "runtime"             = "python3.8"
    "timeout"             = 120
    "memory_size"         = 512
    "lambda_script_folder"  = "../lambdas/"
  }
  LAMBDA_ENVIRONMENT_VARIABLES = {
    "CSV_PATH_LOCATION" = "clients_annual_income.csv"
    "SNS_TOPIC_ARN"     = module.sns-event-producer-topic.arn
    "NUMBER_OF_THREADS" = 10
    "REGION"            = data.aws_region.current.name
  }
}
#endregion
#region SNS
module "sns-event-producer-topic" {
  source          = "./modules/sns/topic"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "event-producer-sns"
}

module "sns-event-producer-subscription" {
  source          = "./modules/sns/subscription"
  SETTINGS = {
    "topic_arn"     = module.sns-event-producer-topic.arn
    "endpoint"      = module.sqs-event-producer.arn
    "protocol"      = "sqs"
    "filter_policy" = ""
  }
}
#endregion

#region SQS
module "sqs-event-producer" {
  source      = "./modules/sqs/"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "event-producer-queue"
  SETTINGS = {
    "delay_seconds"                  = 0
    "max_message_size"               = 262144
    "message_retention_seconds"      = 864000
    "receive_wait_time_seconds"      = 0
    "visibility_timeout_seconds"     = 1200
    "dlq_max_receive_count"          = 1
    "sns_filter_policy_subscription" = ""
    "sns_topic_arn"                  = [module.sns-event-producer-topic.arn]
  }
}
#endregion