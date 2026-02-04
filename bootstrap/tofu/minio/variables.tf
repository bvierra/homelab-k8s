variable "project" {
  description = "Project name"
  type        = string
  default     = "opentofu-state"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "homelab"

  validation {
    condition     = contains(["dev", "staging", "prod", "homelab"], var.environment)
    error_message = "environment must be one of 'dev', 'staging', 'prod', or 'homelab'"
  }
}

variable "minio_server" {
  description = "MinIO server endpoint in the format host:port"
  type        = string
  sensitive   = true
  validation {
    condition     = !can(regex("^https?://", var.minio_server))
    error_message = "minio_server must be in the format host:port"
  }
}

variable "minio_user" {
  description = "MinIO administrator username"
  type        = string
  validation {
    condition     = length(var.minio_user) > 0
    error_message = "minio_user cannot be empty"
  }
}

variable "minio_password" {
  description = "MinIO administrator password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.minio_password) > 0
    error_message = "minio_password cannot be empty"
  }
}

variable "minio_ssl" {
  description = "Use SSL to connect to MinIO server"
  type        = bool
  default     = false
}

variable "minio_insecure" {
  description = "Skip SSL verification when connecting to MinIO server (only used if minio_ssl is true)"
  type        = bool
  default     = false
}

variable "minio_opentofu_user" {
  description = "Username that will be created in MinIO that opentofu will use to store its state file"
  type        = string
  default     = "opentofu"
  validation {
    condition     = length(var.minio_opentofu_user) > 0
    error_message = "minio_opentofu_user cannot be empty"
  }
}

variable "minio_opentofu_autogenerate_keys" {
  description = "Whether to autogenerate the access and secret keys for the opentofu user"
  type        = bool
  default     = true
  validation {
    condition     = var.minio_opentofu_autogenerate_keys && (var.minio_opentofu_accesskey == null || var.minio_opentofu_secretkey == null)
    error_message = "If minio_opentofu_autogenerate_keys is true, both minio_opentofu_accesskey and minio_opentofu_secretkey must be null."
  }
}

variable "minio_opentofu_accesskey" {
  description = "Access key for the opentofu user"
  type        = string
  sensitive   = true
  default     = null
  #validation {
  #  condition     = (var.minio_opentofu_accesskey && var.minio_opentofu_secretkey) || var.minio_opentofu_autogenerate_keys || length(var.minio_opentofu_accesskey) < 8 || length(var.minio_opentofu_accesskey) > 20
  #  error_message = "If minio_opentofu_autogenerate_keys is false, both minio_opentofu_accesskey and minio_opentofu_secretkey must be provided."
  #}
}

variable "minio_opentofu_secretkey" {
  description = "Secret key for the opentofu user"
  type        = string
  sensitive   = true
  default     = null
  #validation {
  #  condition     = var.minio_opentofu_autogenerate_keys || (var.minio_opentofu_accesskey != "" && var.minio_opentofu_secretkey != "") || length(var.minio_opentofu_secretkey) < 8
  #  error_message = "If minio_opentofu_autogenerate_keys is false, both minio_opentofu_accesskey and minio_opentofu_secretkey must be provided."
  #}
}

variable "minio_opentofu_bucket" {
  description = "Name of the bucket where opentofu state files will be stored"
  type        = string
  default     = "opentofu-state"
}

locals {
  minio_opentofu_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.minio_opentofu_bucket}",
          "arn:aws:s3:::${var.minio_opentofu_bucket}/*"
        ]
      }
    ]
  })
}

