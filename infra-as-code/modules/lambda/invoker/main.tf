resource "aws_lambda_permission" "allow" {
  count         = var.SETTINGS["type_arn"] != "" ? 1 : 0 # create one or zero lambda permission
  action        = "lambda:InvokeFunction"
  function_name = var.SETTINGS["lambda_arn"]
  principal     = var.SETTINGS["type_arn"]
  source_arn    = var.SETTINGS["target_arn"]
}