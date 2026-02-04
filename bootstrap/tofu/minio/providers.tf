terraform {
  required_providers {
    minio = {
      source = "terraform-provider-minio/minio"
      version = "3.12.0"
    }
  }
}

provider "minio" {
  minio_server   = "${var.minio_server}"
  minio_user     = "${var.minio_user}"
  minio_password = "${var.minio_password}"
  minio_ssl      = "${var.minio_ssl}"
  minio_insecure = "${var.minio_insecure}"
}
