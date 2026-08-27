variable "subscription_id" {
  description = "Azure subscription hosting the lab"
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group, this lab does not create one"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "francecentral"
}

variable "vm_name" {
  description = "Host VM name"
  type        = string
  default     = "devstack"
}

# Dv5 is unavailable on the shared subscription and the B series has no nested
# virtualization. D4s_v4 exposes VT-x, which Nova needs to run KVM.
variable "vm_size" {
  description = "VM size, must support nested virtualization"
  type        = string
  default     = "Standard_D4s_v4"
}

variable "admin_username" {
  description = "Linux admin user"
  type        = string
  default     = "azureuser"
}

variable "public_key_path" {
  description = "SSH public key injected into the VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "os_disk_size_gb" {
  description = "OS disk size, DevStack clones a lot of sources"
  type        = number
  default     = 64
}

variable "allowed_ssh_cidr" {
  description = "Source allowed to reach port 22, never 0.0.0.0/0"
  type        = string
}
