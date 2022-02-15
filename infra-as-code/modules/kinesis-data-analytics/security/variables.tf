
variable "RESOURCE_NAME" {}

variable "ENV" {}

variable "AWS_TAGS" {
  type = map(string)
}

variable "KDS_INPUT_RESOURCE_NAME" {}

variable "KDS_OUTPUT_RESOURCE_NAME" {}