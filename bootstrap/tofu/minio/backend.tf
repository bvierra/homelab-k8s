locals {
  state_server    = "http://nas01.lab.vierra.host:9000"
  state_bucket    = "opentofu-state"
  state_key       = "${var.environment}/${var.project}/opentofu.tfstate"
  state_insecure  = false
}

terraform {
  backend "s3" {
    endpoint                    = local.state_server
    bucket                      = local.state_bucket
    key                         = local.state_key
    region                      = "default"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_path_style              = true
    insecure                    = local.state_insecure
  }
}
