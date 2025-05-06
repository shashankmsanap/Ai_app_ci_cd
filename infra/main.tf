terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "ai_app" {
  name     = "ai-app-${var.environment}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "ai_app" {
  name                = "ai-app-vnet"
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.ai_app.location
  resource_group_name = azurerm_resource_group.ai_app.name
}

resource "azurerm_network_interface" "ai_app" {
  name                = "ai-app-nic"
  location            = azurerm_resource_group.ai_app.location
  resource_group_name = azurerm_resource_group.ai_app.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ai_app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ai_app.id
  }
}

resource "azurerm_linux_virtual_machine" "ai_app" {
  name                = "ai-app-vm"
  resource_group_name = azurerm_resource_group.ai_app.name
  location            = azurerm_resource_group.ai_app.location
  size                = "Standard_B2s"  # Cost-effective for dev
  admin_username      = var.vm_username
  network_interface_ids = [
    azurerm_network_interface.ai_app.id
  ]

  admin_ssh_key {
    username   = var.vm_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Pre-install Python and dependencies
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    python_version = "3.9"
  }))
}