resource "minio_s3_bucket" "opentofu_state_bucket" {
  bucket = var.minio_opentofu_bucket
  acl    = "private"
}

resource "minio_s3_bucket_versioning" "opentofu_state_bucket" {
  depends_on   = [minio_s3_bucket.opentofu_state_bucket]
  bucket = minio_s3_bucket.opentofu_state_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}
