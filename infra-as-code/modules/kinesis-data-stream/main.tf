locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
}

resource "aws_kinesis_stream" "kinesis_stream" {
  name             = local.RESOURCE_NAME
  shard_count      = var.NUMBER_OF_SHARDS
  retention_period = var.RETENTION_PERIOD

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    environment = var.AWS_TAGS
  }

}