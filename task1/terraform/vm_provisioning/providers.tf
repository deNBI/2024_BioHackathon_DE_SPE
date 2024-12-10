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
