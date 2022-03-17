resource "aws_iam_role" "iam_for_lambda" {
 name               = var.RESOURCE_NAME
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "iam_for_lambda_policy" {
  name   = var.RESOURCE_NAME
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}

data "aws_iam_policy_document" "lambda_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    effect = "Allow"
    sid    = ""
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage",
      "SQS:GetQueueAttributes",
      "SQS:SendMessage",
      "SQS:GetQueueUrl"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${var.RESOURCE_NAME}:*"
    ]
  }
}