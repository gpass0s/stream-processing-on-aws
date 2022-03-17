variable "PROJECT_NAME" {}
variable "ENV" {}
variable "RESOURCE_SUFFIX" {}

variable "LAMBDA_LAYER" {
  type    = list(string)
  default = []
}

variable "LAMBDA_SETTINGS" {
  type = any
}

variable "LAMBDA_EVENT_SOURCE" {
  type = any
  default = {
    "event_source_arn" = ""
    "event_source_url" = ""
    "protocol"         = ""
  }
}

variable LAMBDA_ENVIRONMENT_VARIABLES {
  type = map(string)
}

variable "LAMBDA_INVOKE_FUNCTION" {
  type = any
  default = {
    "type_arn"   = ""
    "target_arn" = ""
  }
}