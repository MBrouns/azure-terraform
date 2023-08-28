
resource azurerm_virtual_network main {
  name = "vnet-webserver-exercise"

  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}


locals {
  web_subnet_cidr = "10.0.0.0/22"
}

module "snet-web" {
  source = "./modules/azure-subnet"

  name = "snet-web"
  cidr_block = local.web_subnet_cidr

  azurerm_resource_group_name  = azurerm_resource_group.main.name
  azurerm_virtual_network_name = azurerm_virtual_network.main.name
  location                     = azurerm_resource_group.main.location
}


resource azurerm_network_security_rule web_allow_http_inbound {
  name                        = "allowHTTPInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = module.snet-web.azurerm_network_security_group_name
}


module "snet-bastion" {
  source = "./modules/azure-subnet"

  name = "snet-bastion"
  cidr_block = "10.0.4.0/22"

  azurerm_resource_group_name  = azurerm_resource_group.main.name
  azurerm_virtual_network_name = azurerm_virtual_network.main.name
  location                     = azurerm_resource_group.main.location
}

resource azurerm_network_security_rule bastion_allow_ssh_inbound {
  name                        = "allowHTTPInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = module.snet-bastion.azurerm_network_security_group_name
}


resource azurerm_network_security_rule web_allow_ssh_inbound_from_bastion {
  name                        = "allowSSHFromBastion"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = local.web_subnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = module.snet-bastion.azurerm_network_security_group_name
}



resource azurerm_network_security_rule web_allow_ssh_inbound_from_home {
  name                        = "allowSSHFromHome"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "80.60.125.218/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = module.snet-web.azurerm_network_security_group_name
}