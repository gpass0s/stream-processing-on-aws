variable "RESOURCE_PREFIX" {}

variable "SETTINGS" {
  type = map(string)
}

variable "SETTINGS_THRESHOLD" {
  type = map(string)

  default = {
    alarm_delivery_s3_data_freshness_threshold = "1800"
  }
}

variable "SETTINGS_ACTIONS" {
  type = map(list(string))

  default = {
    alarm_actions             = []
    ok_actions                = []
    insufficient_data_actions = []
  }
}

variable "AWS_TAGS"