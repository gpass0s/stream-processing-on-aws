variable "ENV" {}

variable "PROJECT_NAME" {}

variable "APP" {}

variable RESOURCE_SUFFIX{}

variable "AWS_TAGS" {
  type = map(string)
}

variable "KDS_INPUT_RESOURCE_NAME" {}

variable "KDS_OUTPUT_RESOURCE_NAME" {}

variable "INPUT_STREAM_NAME" {}

variable "OUTPUT_STREAM_NAME" {}

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

variable "INPUT_STREAM_ARN" {}

variable "OUTPUT_STREAM_ARN" {}

variable "COUNT_VALUE" {
  default = 1
}

variable "ENCODE" {
  default = "UTF-8"
}