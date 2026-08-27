output "node_name" {
  value = openstack_compute_instance_v2.k3s.name
}

output "floating_ip" {
  description = "Address of the node, reachable from the lab host"
  value       = openstack_networking_floatingip_v2.k3s.address
}
