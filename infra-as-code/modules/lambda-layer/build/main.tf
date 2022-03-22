resource "null_resource" "install_python_dependencies" {

  triggers = {
    requirements = base64sha256(file("../${var.BUILD_SETTINGS["requirements_path"]}"))
    build        = base64sha256(file(var.BUILD_SETTINGS["builder_script_path"]))
  }

  provisioner "local-exec" {
    command = "bash ${var.BUILD_SETTINGS["builder_script_path"]}"

    environment = {
      layer_name          = var.BUILD_SETTINGS["layer_name"]
      runtime             = var.BUILD_SETTINGS["runtime"]
      root_directory      = "../"
      package_output_name = var.BUILD_SETTINGS["package_output_name"]
      requirements_path   = var.BUILD_SETTINGS["requirements_path"]
    }
  }
}