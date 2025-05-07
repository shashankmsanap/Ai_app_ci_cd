terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Uncomment if using remote state (recommended for production)
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "yourstorageaccount"
  #   container_name       = "tfstate"
  #   key                  = "ai-app.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

resource "azurerm_resource_group" "ai_app" {
  name     = "ai-app-${var.environment}-rg"
  location = var.location
  tags = {
    Application = "Healthcare AI"
    Environment = var.environment
  }
}

# Network Infrastructure
resource "azurerm_virtual_network" "ai_app" {
  name                = "ai-app-vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ai_app.location
  resource_group_name = azurerm_resource_group.ai_app.name
}

resource "azurerm_subnet" "ai_app" {
  name                 = "ai-app-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.ai_app.name
  virtual_network_name = azurerm_virtual_network.ai_app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "ai_app" {
  name                = "ai-app-pip-${var.environment}"
  location            = azurerm_resource_group.ai_app.location
  resource_group_name = azurerm_resource_group.ai_app.name
  allocation_method   = "Dynamic" # Use "Static" for production
  sku                 = "Basic"
  tags                = azurerm_resource_group.ai_app.tags
}

resource "azurerm_network_security_group" "ai_app" {
  name                = "ai-app-nsg-${var.environment}"
  location            = azurerm_resource_group.ai_app.location
  resource_group_name = azurerm_resource_group.ai_app.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_ip # Restrict to your IP
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000" # App port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "ai_app" {
  name                = "ai-app-nic-${var.environment}"
  location            = azurerm_resource_group.ai_app.location
  resource_group_name = azurerm_resource_group.ai_app.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ai_app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ai_app.id
  }
}

resource "azurerm_network_interface_security_group_association" "ai_app" {
  network_interface_id      = azurerm_network_interface.ai_app.id
  network_security_group_id = azurerm_network_security_group.ai_app.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "ai_app" {
  name                = "ai-app-vm-${var.environment}"
  resource_group_name = azurerm_resource_group.ai_app.name
  location            = azurerm_resource_group.ai_app.location
  size                = "Standard_B2s"  # Burstable for cost savings
  admin_username      = var.vm_username
  custom_data         = base64encode(templatefile("${path.module}/cloud-init.yml", {
    app_repo       = var.app_repository_url
    python_version = "3.9"
  }))

  network_interface_ids = [
    azurerm_network_interface.ai_app.id
  ]

  admin_ssh_key {
    username   = var.vm_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = azurerm_resource_group.ai_app.tags

  lifecycle {
    ignore_changes = [
      custom_data # Prevent redeployment when cloud-init changes
    ]
  }
}