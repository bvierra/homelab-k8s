resource "minio_iam_user" "opentofu" {
  name                = var.minio_opentofu_user
}

resource "minio_iam_user_policy_attachment" "opentofu" {
  depends_on  = [minio_iam_user.opentofu, minio_iam_policy.opentofu-readwrite]
  user_name   = minio_iam_user.opentofu.id
  policy_name = minio_iam_policy.opentofu-readwrite.id
}

# resource "minio_accesskey" "opentofu" {
#   depends_on          = [minio_iam_user.opentofu]
#   user                = minio_iam_user.opentofu.name
#   description         = "opentofu state file access key"
#   lifecycle {
#     enabled           = var.minio_opentofu_autogenerate_keys ? true : false
#   }
# }

resource "random_password" "opentofu_accesskey" {
  length           = 20
  special          = false
}

resource "random_password" "opentofu_secretkey" {
  length           = 32
  special          = false
}

resource "minio_accesskey" "opentofu" {
  depends_on          = [minio_iam_user.opentofu]
  user                = minio_iam_user.opentofu.name
  # access_key          = var.minio_opentofu_accesskey
  # secret_key          = var.minio_opentofu_secretkey
  access_key          = random_password.opentofu_accesskey.result
  secret_key          = random_password.opentofu_secretkey.result
  secret_key_version  = sha256(random_password.opentofu_secretkey.result) # Version identifier for change detection
  status              = "enabled"
  policy              = local.minio_opentofu_policy
  description         = "opentofu state file access key"
}

