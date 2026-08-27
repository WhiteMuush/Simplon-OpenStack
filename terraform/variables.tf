variable "cloud_name" {
  description = "Entry to use from clouds.yaml"
  type        = string
  default     = "lab"
}

variable "instance_name" {
  description = "Instance name"
  type        = string
  default     = "web-01"
}

variable "image_name" {
  description = "System image. CirrOS is 50 MB, ideal for testing."
  type        = string
  default     = "cirros-0.6.2-x86_64-disk"
}

variable "flavor_name" {
  description = "Instance flavor"
  type        = string
  default     = "m1.tiny"
}

variable "network_name" {
  description = "Internal network created by DevStack"
  type        = string
  default     = "private"
}

variable "public_key_path" {
  description = "Public key injected into the instance"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
