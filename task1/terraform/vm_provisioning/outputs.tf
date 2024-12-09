#################### Outputs ####################
# Output the IP address attached to our resource
output "demo_instance_floating_ip" {
  value = openstack_networking_floatingip_v2.floating_ip.address
  # value = openstack_compute_instance_v2.demo.access_ip_v4
}
