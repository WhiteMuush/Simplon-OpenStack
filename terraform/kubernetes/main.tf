resource "openstack_compute_keypair_v2" "k3s" {
  name       = "${var.node_name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "openstack_networking_floatingip_v2" "k3s" {
  pool = var.floating_ip_pool
}

resource "openstack_networking_secgroup_v2" "k3s" {
  name        = "${var.node_name}-sg"
  description = "SSH and the Kubernetes API, from the lab host only"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.k3s.id
}

# 6443 is the Kubernetes API. Reached through an SSH tunnel, never exposed.
resource "openstack_networking_secgroup_rule_v2" "api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.k3s.id
}

# The floating IP is created before the node, so its address can go straight
# into the certificate the API server will present.
resource "openstack_compute_instance_v2" "k3s" {
  name            = var.node_name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.k3s.name
  security_groups = [openstack_networking_secgroup_v2.k3s.name]

  network {
    name = var.network_name
  }

  user_data = <<-CLOUDINIT
    #cloud-config
    package_update: true
    runcmd:
      - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san ${openstack_networking_floatingip_v2.k3s.address} --write-kubeconfig-mode 644" sh -
  CLOUDINIT
}

data "openstack_networking_network_v2" "private" {
  name = var.network_name
}

data "openstack_networking_port_v2" "k3s" {
  device_id  = openstack_compute_instance_v2.k3s.id
  network_id = data.openstack_networking_network_v2.private.id
}

resource "openstack_networking_floatingip_associate_v2" "k3s" {
  floating_ip = openstack_networking_floatingip_v2.k3s.address
  port_id     = data.openstack_networking_port_v2.k3s.id
}
