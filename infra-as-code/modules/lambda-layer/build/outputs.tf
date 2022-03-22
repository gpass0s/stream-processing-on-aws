output "install_python_dependencies" {
  value = null_resource.install_python_dependencies
}

output "package_output_path" {
    value = "../utils/${var.BUILD_SETTINGS["package_output_name"]}.zip"
}