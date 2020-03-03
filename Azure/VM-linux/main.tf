provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.namespace}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "${var.namespace}-vnet"
  address_space       = [var.network_cidr]
}

resource "azurerm_subnet" "main" {
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  name                 = "${var.namespace}-subnet"
  address_prefix       = var.network_cidr
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "azurerm_public_ip" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "${var.namespace}-pubip"
  allocation_method   = "Static"
  domain_name_label   = "${var.namespace}-pubip"
}

resource "azurerm_network_interface" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "${var.namespace}-nic"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    public_ip_address_id          = azurerm_public_ip.main.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  name                             = "${var.namespace}-vm"
  network_interface_ids            = [azurerm_network_interface.main.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
  }

  storage_os_disk {
    name              = "${var.namespace}vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "128"
  }


  os_profile {
    computer_name  = "${var.namespace}vm"
    admin_username = var.admin_username
    admin_password = random_password.password.result

  }
    os_profile_linux_config {
    disable_password_authentication = false
    }
  
}