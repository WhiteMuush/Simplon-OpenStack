resource "openstack_compute_keypair_v2" "lab" {
  name       = "lab-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "openstack_networking_secgroup_v2" "web" {
  name        = "web"
  description = "SSH from the lab network, HTTP open"
}

# Deliberately narrow CIDR: never expose port 22 to 0.0.0.0/0.
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.allowed_ssh_cidr
  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = var.allowed_http_cidr
  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_compute_instance_v2" "vm" {
  name            = var.instance_name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.lab.name
  security_groups = [openstack_networking_secgroup_v2.web.name]

  network {
    name = var.network_name
  }
}

# Reachable from the lab host, which is what makes `ssh -J` work from the
# workstation: the private network alone is unreachable outside the host.
resource "openstack_networking_floatingip_v2" "vm" {
  pool = var.floating_ip_pool
}

# Provider v3 dropped the compute-side association, so it goes through the
# instance port on the networking side.
data "openstack_networking_network_v2" "private" {
  name = var.network_name
}

data "openstack_networking_port_v2" "vm" {
  device_id  = openstack_compute_instance_v2.vm.id
  network_id = data.openstack_networking_network_v2.private.id
}

resource "openstack_networking_floatingip_associate_v2" "vm" {
  floating_ip = openstack_networking_floatingip_v2.vm.address
  port_id     = data.openstack_networking_port_v2.vm.id
}

# ICMP kept as narrow as SSH: handy to demonstrate, not open to anyone.
resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.allowed_ssh_cidr
  security_group_id = openstack_networking_secgroup_v2.web.id
}
