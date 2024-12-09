#################### Floating IPs ####################
# Lets create a floating IP
resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = "external"
}

# Attach our floating IP to the instance
resource "openstack_compute_floatingip_associate_v2" "float_ip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.demo.id
}

#################### Volumes ####################
resource "openstack_blockstorage_volume_v3" "scratch_volume" {
  name        = "${var.name_prefix}_scratch_volume"
  size        = 2
}

# Attach our volume to the instance
resource "openstack_compute_volume_attach_v2" "scratch_volume_attach" {
  instance_id = openstack_compute_instance_v2.demo.id
  volume_id   = openstack_blockstorage_volume_v3.scratch_volume.id
}