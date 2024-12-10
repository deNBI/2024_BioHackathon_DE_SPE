#################### Security Groups ####################
# Lets create a couple of security groups to allow SSH and outgoing connections
resource "openstack_networking_secgroup_v2" "ssh-public" {
  name                 = "${var.name_prefix}_ssh_public"
  description          = "[TF] Allow SSH connections from anywhere"
  delete_default_rules = "true"
}

resource "openstack_networking_secgroup_rule_v2" "public-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.ssh-public.id
}

resource "openstack_networking_secgroup_v2" "egress-public" {
  name                 = "${var.name_prefix}_egress_public"
  description          = "[TF] Allow any outgoing connection"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "public-egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.egress-public.id
}

# Create HTTP security group
resource "openstack_networking_secgroup_v2" "http-public" {
  name                 = "${var.name_prefix}_http_public"
  description          = "[TF] Allow HTTP connections from anywhere"
  delete_default_rules = "true"
}

resource "openstack_networking_secgroup_rule_v2" "http-public" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.http-public.id
}


# Create HTTPS security group
resource "openstack_networking_secgroup_v2" "https-public" {
  name                 = "${var.name_prefix}_https_public"
  description          = "[TF] Allow HTTPS connections from anywhere"
  delete_default_rules = "true"
}

resource "openstack_networking_secgroup_rule_v2" "https-public" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.https-public.id
}
