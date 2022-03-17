locals {
  BUCKET_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
}

#### Bucket S3 ####

resource "aws_s3_bucket" "bucket" {
  bucket = local.BUCKET_NAME
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  bucket = aws_s3_bucket.bucket.id
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecicyle_configuration" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "expires_versioned_objects"
    status = var.ENABLE_LIFECYCLE

    expiration {
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.ENABLE_VERSIONING
  }
}




