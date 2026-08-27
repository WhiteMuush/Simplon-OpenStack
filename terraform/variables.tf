variable "cloud_name" {
  description = "Entrée à utiliser dans clouds.yaml"
  type        = string
  default     = "lab"
}

variable "instance_name" {
  description = "Nom de l'instance"
  type        = string
  default     = "web-01"
}

variable "image_name" {
  description = "Image système. CirrOS pèse 50 Mo, idéal pour tester."
  type        = string
  default     = "cirros-0.6.2-x86_64-disk"
}

variable "flavor_name" {
  description = "Gabarit de l'instance"
  type        = string
  default     = "m1.tiny"
}

variable "network_name" {
  description = "Réseau interne créé par DevStack"
  type        = string
  default     = "private"
}

variable "public_key_path" {
  description = "Clé publique injectée dans l'instance"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
