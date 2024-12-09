# Lets get the latest ubuntu image id using data block
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 22.04 LTS (2023-09-28)"
  most_recent = true
}

# Lets create an instance
resource "openstack_compute_instance_v2" "demo" {
  name            = "${var.name_prefix}_demo"
  flavor_name     = "de.NBI tiny"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  key_pair        = openstack_compute_keypair_v2.my-cloud-key.name
  security_groups = ["${var.name_prefix}_ssh", "${var.name_prefix}_egress_public"]

  network {
    name = "tf-network"
  }
}
