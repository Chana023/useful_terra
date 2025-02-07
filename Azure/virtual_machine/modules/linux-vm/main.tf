resource "azurerm_resource_group" "vm-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vm-vnet" {
  name                = "vnet-${var.vm_name}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.vm-rg.name
}

resource "azurerm_subnet" "vm-subnet" {
  name                 = "subnet-${var.vm_name}"
  resource_group_name  = azurerm_resource_group.vm-rg.name
  virtual_network_name = azurerm_virtual_network.vm-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg-${var.vm_name}"
  location = var.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  dynamic "security_rule" {
    for_each = var.inbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  dynamic "security_rule" {
    for_each = var.outbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_public_ip" "vm-public-ip" {
  name                = "pip-${var.vm_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vm-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-public-ip.id

  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.vm-rg.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.vm-nic.id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

}