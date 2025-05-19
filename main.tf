terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.29.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "aee94afd-b039-4282-88ac-51ce582077df"
}

resource "azurerm_resource_group" "production" {
  name     = "UKG"
  location = "Central India"
}

resource "azurerm_virtual_network" "productionnetwork" {
  name                = "ukgvnet"
  location            = "central india"
  resource_group_name = azurerm_resource_group.production.name
  address_space       = ["11.0.0.0/16"]



}


resource "azurerm_subnet" "productionsubnet" {
  name                 = "ukgsubnet"
  resource_group_name  = azurerm_resource_group.production.name
  virtual_network_name = azurerm_virtual_network.productionnetwork.name
  address_prefixes     = ["11.0.2.0/24"]
}


resource "azurerm_network_interface" "productionnic" {
  name                = "ukgnic"
  location            = azurerm_resource_group.production.location
  resource_group_name = azurerm_resource_group.production.name

  ip_configuration {
    name                          = "ukgip"
    subnet_id                     = azurerm_subnet.productionsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_virtual_machine" "productionvm" {
  name                  = "ukgvm"
  location              = azurerm_resource_group.production.location
  resource_group_name   = azurerm_resource_group.production.name
  network_interface_ids = [azurerm_network_interface.productionnic.id]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "ukgdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ukghost"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}