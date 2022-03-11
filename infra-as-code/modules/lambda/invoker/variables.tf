variable "SETTINGS" {
  type    = map(string)
  default = {
    "lambda_arn" = ""
    "type_arn"   = ""
    "target_arn" = ""
  }
}