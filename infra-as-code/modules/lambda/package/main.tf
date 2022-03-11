data "archive_file" "script" {
  type = var.PACKAGE_SETTINGS["type"]
  source_dir =  "../${var.PACKAGE_SETTINGS["filename"]}"
  output_path = "../${var.PACKAGE_SETTINGS["filename"]}.${var.PACKAGE_SETTINGS["type"]}"

}