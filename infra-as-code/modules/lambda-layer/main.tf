locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
}

module "build" {
  source = "./build"
  BUILD_SETTINGS  {
    builder_script_path = var.BUILDER_SCRIPT_PATH
    function_name       = var.RESOURCE_SUFFIX
    runtime             = var.PYTHON_RUNTIME
    package_output_name = var.PACKAGE_OUTPUT_NAME
    requirements_path   = var.REQUIREMENTS_PATH
  }
}

resource "aws_lambda_layer_version" "python-layer" {
  filename            = module.build.package_output_path
  layer_name          = var.RESOURCE_SUFFIX
  source_code_hash    = filebase64sha256(module.build.package_output_path)
  compatible_runtimes = [var.PYTHON_RUNTIME]
  depends_on = [module.build.install_python_dependencies]
}