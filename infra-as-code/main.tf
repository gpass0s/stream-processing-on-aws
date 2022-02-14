module "codepipeline-artifacts-bucket" {
  source          = "./modules/s3"
  ENV             = "prd"
  PROJECT_NAME    = "streaming-processing"
  RESOURCE_SUFFIX = "codepipeline-artifacts"
  AWS_TAGS        = "streaming-processing"
}