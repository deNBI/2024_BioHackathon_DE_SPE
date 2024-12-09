# Lets get the latest ubuntu image id using data block
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 24.04 LTS (2024-11-22)"
  most_recent = true
}

# Lets create an instance
resource "openstack_compute_instance_v2" "demo" {
  name            = "${var.name_prefix}"
  flavor_name     = "de.NBI small + ephemeral"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  key_pair        = openstack_compute_keypair_v2.my-cloud-key.name
  # security_groups = ["${var.name_prefix}_ssh", "${var.name_prefix}_egress_public", "${var.name_prefix}_https"]
  security_groups = [openstack_networking_secgroup_v2.ssh-public.name, openstack_networking_secgroup_v2.egress-public.name, openstack_networking_secgroup_v2.https-public.name]

  network {
    name = "SeProEnv_net"
  }
}
