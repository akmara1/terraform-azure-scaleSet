#network security group
resource "azurerm_network_security_group" "example" {
  name                = "nsg-${var.name}"
  location            = var.loc
  resource_group_name = var.rg

  dynamic "security_rule" {
    for_each = local.list
    content {
      name                       = security_rule.key
      priority                   = security_rule.value["priority"]
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = security_rule.value["dest_port"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
  }
}

# scale set
resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "scale-set"
  resource_group_name = var.rg
  location            = var.loc
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = "Akmaral@1234567"
  disable_password_authentication = false
  custom_data         = filebase64("web.conf")

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  network_interface {
    name                      = "nic-${var.name}"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.example.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet
      load_balancer_backend_address_pool_ids = [var.backend_pool]
      load_balancer_inbound_nat_rules_ids    = [var.nat_pool]
    }
  }
}
