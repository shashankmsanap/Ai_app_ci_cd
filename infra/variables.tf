variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "vm_username" {
  description = "Admin username for VM"
  type        = string
  sensitive   = true
}
