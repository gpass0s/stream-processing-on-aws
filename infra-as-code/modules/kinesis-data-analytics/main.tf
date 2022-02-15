locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
}

module "security" {
  source                    = "./security"
  RESOURCE_NAME             = local.RESOURCE_NAME
  AWS_TAGS                  = var.AWS_TAGS
  ENV                       = var.ENV
  KDS_INPUT_RESOURCE_NAME   = var.KDS_INPUT_RESOURCE_NAME
  KDS_OUTPUT_RESOURCE_NAME  = var.KDS_OUTPUT_RESOURCE_NAME
}

resource "aws_kinesis_analytics_application" "kda_application" {
  name = local.RESOURCE_NAME
  code = var.SQL_CODE_PATH

  inputs {
    name_prefix = var.INPUT_STREAM_NAME

    kinesis_stream {
      resource_arn = var.INPUT_STREAM_ARN
      role_arn     = module.security.role-kinesis-analytics-arn
    }

    parallelism {
      count = var.COUNT_VALUE
    }

    schema {
      dynamic "record_columns" {
        for_each = var.INPUT_SCHEMA_COLUMNS
        content {
          mapping = record_columns.value["mapping"]
          name = record_columns.value["name"]
          sql_type = record_columns.value["sql_type"]
        }
      }
        record_encoding = var.ENCODE
        record_format {
          mapping_parameters {
            json {
              record_row_path = var.RECORD_ROW_PATH
            }
          }
        }
    }
  }

  reference_data_sources {
    table_name = var.REFERENCE_TABLE_NAME
    s3 {
      bucket_arn = var.REFERENCE_TABLE_BUCKET_ARN
      file_key = var.REFERENCE_TABLE_S3_FILE_KEY
      role_arn = module.security.role-kinesis-analytics-arn
    }
    schema {
      dynamic "record_columns" {
        for_each = var.REFERENCE_TABLE_SCHEMA_COLUMNS
        content {
          mapping = record_columns.value["mapping"]
          name = record_columns.value["name"]
          sql_type = record_columns.value["sql_type"]
        }
      }
      record_format {
        mapping_parameters {
          csv {
            record_column_delimiter = ","
            record_row_delimiter    = "|"
          }
        }
      }
    }
  }

  outputs {
    name = var.OUTPUT_STREAM_NAME

    kinesis_stream {
      resource_arn = var.OUTPUT_STREAM_ARN
      role_arn = module.security.role-kinesis-analytics-arn
    }

    schema {
      record_format_type = "JSON"
    }

  }
  start_application = false
}