data "archive_file" "script" {
  type = var.PACKAGE_SETTINGS["type"]
  source_dir =  "${var.PACKAGE_SETTINGS["lambda_script_folder"]}"
  output_path = "../utils/lambdas-deployment-packages/${var.PACKAGE_SETTINGS["folder_output_name"]}.${var.PACKAGE_SETTINGS["type"]}"
}