resource "aws_sqs_queue_policy" "policy" {
  queue_url = var.SQS_QUEUE_ID
  policy    = data.aws_iam_policy_document.queue_policy.json
}

data "aws_iam_policy_document" "queue_policy" {
  policy_id = "${var.SQS_QUEUE_ARN}/SQSDefaultPolicy"

  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage"
    ]

    resources = [
      var.SQS_QUEUE_ARN
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values =var.SNS_TOPIC_ARN
    }
  }
}