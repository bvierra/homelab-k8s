resource "minio_iam_policy" "opentofu-readwrite" {
  name = "opentofu-readwrite"
  policy = local.minio_opentofu_policy
}
