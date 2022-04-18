data "aws_region" "current_region" {}

locals {
  PROJECT_NAME                 = "streaming-processing"
  ENV                          = "dev"
  AWS_REGION                   = data.aws_region.current_region.name
}

#region S3
#Creates a S3 bucket
module "project-artifacts-bucket" {
  source          = "./modules/s3"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "codepipeline-artifacts"
}

#Uploads the reference table to S3
resource "aws_s3_object" "reference-table" {
  key = "reference-table/clients_annual_income.csv"
  bucket = module.project-artifacts-bucket.id
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
    "timeout"             = 900
    "memory_size"         = 512
    "lambda_script_folder"  = "../lambdas/"
  }
  LAMBDA_ENVIRONMENT_VARIABLES = {
    "CSV_PATH_LOCATION" = "clients_annual_income.csv"
    "SNS_TOPIC_ARN"     = module.sns-event-producer-topic.arn
    "NUMBER_OF_THREADS" = 10
    "REGION"            = local.AWS_REGION
  }
}

module "lambda-event-flattener" {
  source          = "./modules/lambda"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "event-flattener"
  LAMBDA_SETTINGS = {
    "description"           = "This function flattens and standardizes the event schemas"
    "handler"               = "event_flattener.lambda_handler"
    "runtime"               = "python3.8"
    "timeout"               = 120
    "memory_size"           = 256
    "lambda_script_folder"  = "../lambdas/"
  }
  LAMBDA_ENVIRONMENT_VARIABLES = {"KDS_NAME" = module.kds-input.name}
  LAMBDA_EVENT_SOURCE = {
    event_source_arn    = module.sqs-event-producer.arn
    trigger             = "sqs"
  }
}

module "lambda-kinesis-output" {
  source          = "./modules/lambda"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "kinesis-output"
  LAMBDA_SETTINGS = {
    "description"           = "This function receives kinesis data analytics output"
    "handler"               = "kinesis_output.lambda_handler"
    "runtime"               = "python3.8"
    "timeout"               = 120
    "memory_size"           = 128
    "lambda_script_folder"  = "../lambdas/"
  }
  LAMBDA_ENVIRONMENT_VARIABLES = {"KDS_NAME" = module.kds-input.name}
  LAMBDA_EVENT_SOURCE = {
    event_source_arn    = module.kds-output.arn
    trigger             = "kinesis"
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
  source          = "./modules/sqs/"
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

#region KDS
module "kds-input" {
  source    = "./modules/kinesis-data-stream"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "input-stream"
}

module "kds-output" {
  source    = "./modules/kinesis-data-stream"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  RESOURCE_SUFFIX = "output-stream"
}
#endregion

# region KDA

locals {

}

module "kda-join-streams" {
  source                              = "./modules/kinesis-data-analytics"
  ENV                                 = local.ENV
  PROJECT_NAME                        = local.PROJECT_NAME
  RESOURCE_SUFFIX                     = "join-streams"
  INPUT_STREAM_NAME                   = "INPUT_STREAM"
  INPUT_SCHEMA_COLUMNS                = var.KDA_STREAM_INPUT_SCHEMA
  RECORD_ROW_PATH                     = "$"
  SQL_CODE_PATH                       = file("../kinesis_data_analytics_application.sql")
  KDS_INPUT_ARN                       = module.kds-input.arn
  REFERENCE_TABLE_S3_ARN              = "arn:aws:s3:::${aws_s3_object.reference-table.bucket}/${aws_s3_object.reference-table.key}"
  REFERENCE_TABLE_BUCKET_ARN          = module.project-artifacts-bucket.arn
  REFERENCE_TABLE_NAME                = "REFERENCE_TABLE"
  REFERENCE_TABLE_S3_FILE_KEY         = aws_s3_object.reference-table.key
  REFERENCE_TABLE_SCHEMA_COLUMNS      = var.KDA_REFERENCE_TABLE_SCHEMA
  OUTPUT_STREAM_NAME                  = "OUTPUT_STREAM"
  KDS_OUTPUT_ARN                      = module.kds-output.arn
  REFERENCE_TABLE_RECORD_FORMAT       = {
    "record_column_delimiter"     = ";"
    "record_row_delimiter"        = "\n"
  }
}
# endregion