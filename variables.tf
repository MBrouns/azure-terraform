variable webserver_count {
  default = 2
}


variable "vm_image" {
  default = {
    "publisher" = "Canonical"
    "offer"     = "0001-com-ubuntu-server-jammy"
    "sku"       = "22_04-lts-gen2"
    "version"   = "latest"
  }
}