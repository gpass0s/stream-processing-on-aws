resource "null_resource" "install_python_dependencies" {

  triggers {
    handler      = base64sha256(file("../${path.root}/${var.BUILD_SETTINGS["funtion_path"]}"))
    requirements = base64sha256(file("../${path.root}/${var.BUILD_SETTINGS["requirements_path"]}"))
    build        = base64sha256(file("../${path.root}/${var.BUILD_SETTINGS["builder_script_path"]}"))
  }

  provisioner "local-exec" {
    command = "../${path.root}/${var.BUILD_SETTINGS["builder_script_path"]}"

    environment = {
      function_name       = var.BUILD_SETTINGS["function_name"]
      runtime             = var.BUILD_SETTINGS["runtime"]
      root_directory      = "../${path.root}"
      package_output_name = var.BUILD_SETTINGS["package_output_name"]
      requirements_path   = var.BUILD_SETTINGS["requirements_path"]
    }
  }
}
