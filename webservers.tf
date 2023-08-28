

resource "azurerm_public_ip" "webserver" {
  count = 2
  name                = "web-test-ip-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "nic" {
  count               = var.webserver_count
  name                = "nic-web-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = module.snet-web.azurerm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.webserver.*.id, count.index)
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  count                 = var.webserver_count
  name                  = "web-${count.index}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]

  admin_username = "webadmin"
  size           = "Standard_D2s_v3"

  admin_ssh_key {
    username   = "webadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count = var.webserver_count
  name                 = "AADLogin"
  virtual_machine_id   = azurerm_linux_virtual_machine.web[count.index].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux" # For Windows VMs: AADLoginForWindows
  type_handler_version = "1.0" # There may be a more recent version
}

resource "azurerm_virtual_machine_extension" "bootscript" {
  count = var.webserver_count
  name                 = "hostname"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  virtual_machine_id = azurerm_linux_virtual_machine.web[count.index].id

  settings = <<EOF
    {
        "commandToExecute": "DEBIAN_FRONTEND=noninteractive sudo apt-get update && sudo apt-get install -y nginx"
    }
EOF

  tags = {
    environment = "Production"
  }

}

