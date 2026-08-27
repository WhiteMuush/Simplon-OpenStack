output "instance_id" {
  value = openstack_compute_instance_v2.vm.id
}

output "instance_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}
