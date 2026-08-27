resource "openstack_compute_keypair_v2" "lab" {
  name       = "lab-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "openstack_networking_secgroup_v2" "web" {
  name        = "web"
  description = "SSH depuis le bastion, HTTP ouvert"
}

# Le CIDR est volontairement restreint : jamais 0.0.0.0/0 sur le port 22.
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "172.24.4.0/24"
  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
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
