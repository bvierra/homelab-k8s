output "minio_opentofu_bucket_id" {
  value = minio_s3_bucket.opentofu_state_bucket.id
}

output "minio_opentofu_bucket_url" {
  value = minio_s3_bucket.opentofu_state_bucket.bucket_domain_name
}

output "minio_opentofu_user_name" {
  value = minio_iam_user.opentofu.name
}

output "minio_opentofu_user_access_key" {
  value = minio_accesskey.opentofu.access_key
  sensitive = true
}

output "minio_opentofu_user_secret_key" {
  value     = random_password.opentofu_secretkey.result
  sensitive = true
}
