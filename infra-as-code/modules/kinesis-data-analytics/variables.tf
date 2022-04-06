variable "ENV" {}

variable "PROJECT_NAME" {}

variable RESOURCE_SUFFIX{}

variable INPUT_STREAM_NAME {}

variable OUTPUT_STREAM_NAME {}

variable "REFERENCE_TABLE_S3_ARN" {}

variable SQL_CODE_PATH {}

variable "INPUT_SCHEMA_COLUMNS" {
  type = list(object({
    mapping   = string
    name      = string
    sql_type  = string
  }))
  default = []
}

variable "RECORD_ROW_PATH" {
  type = string
  default = "$"
}

variable "REFERENCE_TABLE_NAME" {
  default = ""
}

variable "REFERENCE_TABLE_BUCKET_ARN" {
  default = ""
}

variable "REFERENCE_TABLE_S3_FILE_KEY" {
  default = ""
}

variable "REFERENCE_TABLE_SCHEMA_COLUMNS"{
    type = list(object({
    mapping   = string
    name      = string
    sql_type  = string
  }))
  default = []
}

variable "KDS_INPUT_ARN" {}

variable "KDS_OUTPUT_ARN" {}

variable "COUNT_VALUE" {
  default = 1
}

variable "ENCODE" {
  default = "UTF-8"
}

variable "REFERENCE_TABLE_RECORD_FORMAT" {
  type = any
  default = {
    record_column_delimiter = "\n"
    record_row_delimiter    = ","
  }
}