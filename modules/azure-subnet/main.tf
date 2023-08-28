
resource azurerm_subnet main {
  name = var.name

  address_prefixes     = [var.cidr_block]
  resource_group_name  = var.azurerm_resource_group_name
  virtual_network_name = var.azurerm_virtual_network_name
}


resource azurerm_network_security_group sg_subnet {
  name                = "sg-${var.name}"

  location            = var.location
  resource_group_name = var.azurerm_resource_group_name
}

resource azurerm_network_security_rule sg_deny_rest_inbound {
  name                        = "disallowRest"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.azurerm_resource_group_name
  network_security_group_name = azurerm_network_security_group.sg_subnet.name
}

resource azurerm_subnet_network_security_group_association main {

  network_security_group_id = azurerm_network_security_group.sg_subnet.id
  subnet_id                 = azurerm_subnet.main.id
}