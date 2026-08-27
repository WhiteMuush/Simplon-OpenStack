output "instance_id" {
  value = openstack_compute_instance_v2.vm.id
}

output "instance_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}

output "floating_ip" {
  description = "Address to reach the instance, through the lab host"
  value       = openstack_networking_floatingip_v2.vm.address
}

output "ssh_command" {
  description = "Ready to paste, jumps through the lab host"
  value       = "ssh -J ${var.admin_hint} cirros@${openstack_networking_floatingip_v2.vm.address}"
}

output "instance_name" {
  description = "Name of the instance in OpenStack, not the Linux login"
  value       = openstack_compute_instance_v2.vm.name
}
