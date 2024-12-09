#################### Key Pairs ####################
# To create a key pair, so that we can ssh into the instance later
resource "openstack_compute_keypair_v2" "my-cloud-key" {
  name       = var.public_key["name"]
  public_key = var.public_key["pubkey"]
}
