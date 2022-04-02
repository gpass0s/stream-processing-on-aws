resource "aws_lambda_event_source_mapping" "sqs" {
  batch_size       = 10
  count            = var.SETTINGS["trigger"] == "sqs" ? 1 : 0
  event_source_arn = var.SETTINGS["event_source_arn"]
  function_name    = var.SETTINGS["lambda_arn"]
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  count                              = var.SETTINGS["trigger"] == "kinesis" ? 1 : 0
  event_source_arn                   = var.SETTINGS["event_source_arn"]
  function_name                      = var.SETTINGS["lambda_arn"]
  starting_position                  = "LATEST"
}