locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
}

resource "aws_sqs_queue" "queue" {
  name                       = local.RESOURCE_NAME
  delay_seconds              = var.SETTINGS["delay_seconds"]
  max_message_size           = var.SETTINGS["max_message_size"]
  message_retention_seconds  = var.SETTINGS["message_retention_seconds"]
  receive_wait_time_seconds  = var.SETTINGS["receive_wait_time_seconds"]
  visibility_timeout_seconds = var.SETTINGS["visibility_timeout_seconds"]
}

module "security" {
  source              = "./security"
  SQS_QUEUE_ARN       = aws_sqs_queue.queue.arn
  SQS_QUEUE_ID        = aws_sqs_queue.queue.id
  SNS_TOPIC_ARN       = var.SETTINGS["sns_topic_arn"]
}