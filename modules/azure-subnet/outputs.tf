output "azurerm_network_security_group_name" {
  value = azurerm_network_security_group.sg_subnet.name
}

output "azurerm_subnet_id" {
  value = azurerm_subnet.main.id
}