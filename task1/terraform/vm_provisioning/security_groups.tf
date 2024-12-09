#################### Security Groups ####################
# Lets create a couple of security groups to allow SSH and outgoing connections
resource "openstack_networking_secgroup_v2" "public-ssh" {
  name                 = "${var.name_prefix}_ssh"
  description          = "[TF] Allow SSH connections from anywhere"
  delete_default_rules = "true"
}

resource "openstack_networking_secgroup_rule_v2" "public-ssh-4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.public-ssh.id
}

resource "openstack_networking_secgroup_v2" "egress-public" {
  name                 = "${var.name_prefix}_egress_public"
  description          = "[TF] Allow any outgoing connection"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "egress-public-4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.egress-public.id
}