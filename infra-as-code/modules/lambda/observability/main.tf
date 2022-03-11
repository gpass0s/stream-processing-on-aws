#Creates a log group for lambda functions
resource "aws_cloudwatch_log_group" "log_for_lambda" {
  name              = "/aws/lambda/${var.OBSERVABILITY_SETTINGS["lambda_function_name"]}"
  retention_in_days = var.OBSERVABILITY_SETTINGS["log_retention_in_days"]
  tags              = var.AWS_TAGS
}