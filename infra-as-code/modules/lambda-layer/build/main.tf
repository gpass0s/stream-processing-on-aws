resource "null_resource" "install_python_dependencies" {

  triggers = {
    always_run = timestamp()
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

/*data "archive_file" "my_lambda_function_with_dependencies" {
  depends_on  = [null_resource.install_python_dependencies]
  source_dir  = "../${path.root}/lambdas/"
  output_path = "../${path.root}/${var.BUILD_SETTINGS["package_output_name"]}.zip"
  type        = "zip"
}*/