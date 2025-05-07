variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], lower(var.environment))
    error_message = "Environment must be 'dev', 'stage', or 'prod' (case insensitive)."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
  validation {
    condition     = contains([
      "westeurope", 
      "northeurope",
      "eastus",
      "eastus2"
    ], lower(var.location))
    error_message = "Use Azure regions: westeurope, northeurope, eastus, or eastus2."
  }
}

variable "vm_username" {
  description = "Admin username for VM (must not be 'admin', 'root', or 'azureuser')"
  type        = string
  sensitive   = true
  validation {
    condition     = !contains(["admin", "root", "azureuser"], lower(var.vm_username))
    error_message = "Avoid default usernames for security."
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_source_ip" {
  description = "Allowed IP/CIDR for SSH access (e.g., '203.0.113.1/32')"
  type        = string
  default     = "0.0.0.0/0" # Warning: Restrict this in production!
}

variable "app_repository_url" {
  description = "Git repository URL for application code"
  type        = string
  default     = "https://github.com/shashankmsanap/Ai_app_ci_cd.git"
}

variable "vm_size" {
  description = "Azure VM size (Standard_B2s for dev, Standard_D2s_v3 for prod)"
  type        = string
  default     = "Standard_B2s"
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP to the VM"
  type        = bool
  default     = true
}

variable "allowed_app_port" {
  description = "Application port to expose (5000 for Flask)"
  type        = number
  default     = 5000
  validation {
    condition     = var.allowed_app_port > 1024 && var.allowed_app_port < 65535
    error_message = "Port must be between 1025 and 65534."
  }
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {
    "Application" = "Healthcare AI"
    "ManagedBy"   = "Terraform"
  }
}