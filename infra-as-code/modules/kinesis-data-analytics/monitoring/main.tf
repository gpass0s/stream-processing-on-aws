##### FIREHOSE LOG  #####

resource "aws_cloudwatch_log_group" "log_for_firehose" {
  name              = var.SETTINGS["log_group_name"]
  retention_in_days = 30
  tags              = var.AWS_TAGS
}

resource "aws_cloudwatch_log_stream" "logstream_for_firehose" {
  name           = var.SETTINGS["log_stream_name"]
  log_group_name = aws_cloudwatch_log_group.log_for_firehose.name
}

#### FIREHOSE S3 METRICS ####

resource "aws_cloudwatch_metric_alarm" "delivery_s3_data_freshness" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmDeliveryToS3DataFreshness"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DeliveryToS3.DataFreshness"
  namespace           = "AWS/Firehose"
  alarm_description   = "A idade (da chegada ao Kinesis Data Firehose até agora) do registro mais antigo no Kinesis Data Firehose. Qualquer registro mais antigo que esse foi enviado para o bucket do S3."
  period              = "300"
  statistic           = "Average"
  unit                = "Seconds"
  datapoints_to_alarm = "1"
  threshold           = var.SETTINGS_THRESHOLD["alarm_delivery_s3_data_freshness_threshold"]
  dimensions = {
    DeliveryStreamName = var.RESOURCE_PREFIX
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}