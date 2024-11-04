terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

provider "azurerm" {
    features {
        virtual_machine {
      delete_os_disk_on_deletion            = true
    }
    }
    subscription_id = "4035f9f8-8735-4860-bfcb-748cc65bd38b"
}

resource "azurerm_resource_group" "prod" {
  name     = "TerraformRG"
  location = "West Europe"
}

resource "azurerm_network_security_group" "prodSG" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name

  security_rule {
    name                       = "firewallproduction"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "prodnetwork" {
  name                = "example-network"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  address_space       = ["10.0.0.0/16"]
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "prodsubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prodnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "prodnie" {
  name                = "example-nic"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prodsubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "controlprod" {
  name                = "control-plane"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.prodnie.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("install.agent.sh")
}