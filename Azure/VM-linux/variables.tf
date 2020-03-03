
variable "namespace" {
  description = "Name to assign to resources for easy organization"
  default     = "tfepoc"
}

variable "admin_username" {
  description = "OS level administrator"
  default     = "hashicorp"
}


variable "location" {
  description = "The Azure region to deploy all infrastructure to."
  default     = "West Europe"
}

variable "network_cidr" {
  description = "The network address CIDR for the Vnet/Subnet."
  default     = "10.0.0.0/24"
}

variable "vm_size" {
  description = "The VM size to create."
  default     = "Standard_D2_v2"
}

variable "os_publisher" {
  description = "OS Publisher"
  default     = "Canonical"
}

variable "os_offer" {
  description = "OS offer type"
  default     = "UbuntuServer"
}

variable "os_sku" {
  description = "OS SKU"
  default     = "16.04-LTS"
}

variable "os_version" {
  description = "OS version"
  default     = "latest"
}