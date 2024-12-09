#################### Provider ####################
# To use the OpenStack provider, we need to specify the provider block
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.53.0"
    }
  }
}

# provider "openstack" {
#   user_name   = var.user_name
#   tenant_name = var.tenant_name
#   password    = var.password
#   auth_url    = var.auth_url
#   region      = var.region
#   insecure    = true
# }