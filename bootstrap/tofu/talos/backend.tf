locals {

  state_insecure  = true
  state_server    = "http://garage.lab.vierra.host:3900"
  state_bucket    = "tofu"
  state_key       = "${var.environment}/${var.project}/opentofu.tfstate"
}

terraform {
  backend "s3" {
    endpoint                    = local.state_server
    bucket                      = local.state_bucket
    key                         = local.state_key
    region                      = "garage"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    insecure                    = local.state_insecure
  }
}
