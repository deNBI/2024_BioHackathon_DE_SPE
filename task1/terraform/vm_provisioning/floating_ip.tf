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
