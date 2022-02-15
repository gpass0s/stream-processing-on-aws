variable "ENV" {}

variable "PROJECT_NAME" {}

variable "AWS_TAGS" {}

variable "NUMBER_OF_SHARDS" {
  default = 1
}

variable "RETENTION_PERIOD" {
  default = 24
}

variable "RESOURCE_SUFFIX" {}
