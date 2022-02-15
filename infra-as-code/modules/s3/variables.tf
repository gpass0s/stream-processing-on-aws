variable "ENV" {}

variable "PROJECT_NAME" {}

variable "RESOURCE_SUFFIX" {}

variable "AWS_TAGS" {}

variable "ENABLE_LIFECYCLE" {
  default = "Disabled"
}
variable "ENABLE_VERSIONING" {
  default = "Suspended"
}