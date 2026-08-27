variable "cloud_name" {
  description = "Entry to use from clouds.yaml"
  type        = string
  default     = "lab"
}

variable "node_name" {
  description = "Name of the k3s node"
  type        = string
  default     = "k3s-01"
}

# Single node on purpose: the lab host has 8 GB, three of them already taken by
# OpenStack itself. This demonstrates the chain, not high availability.
variable "flavor_name" {
  description = "Flavor of the node, needs 2 GB minimum"
  type        = string
  default     = "m1.small"
}

variable "image_name" {
  description = "Ubuntu image, uploaded to Glance by the playbook"
  type        = string
  default     = "ubuntu-22.04"
}

variable "network_name" {
  description = "Internal network created by DevStack"
  type        = string
  default     = "private"
}

variable "floating_ip_pool" {
  description = "External network the floating IP is taken from"
  type        = string
  default     = "public"
}

variable "public_key_path" {
  description = "Public key injected into the node"
  type        = string
}

variable "allowed_cidr" {
  description = "Source allowed to reach SSH and the Kubernetes API"
  type        = string
}
