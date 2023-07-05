#Creating 5 network interface for our VMs
resource "azurerm_network_interface" "nic1" {
  for_each            = var.vm_details
  name                = each.value.nic
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name

  ip_configuration {
    name                          = "${each.value.nic}-ipconfig"
    subnet_id                     = azurerm_subnet.net1.id
    private_ip_address_allocation = "Dynamic"
  }
}
#Creating 5 VMs (Windows server)
resource "azurerm_windows_virtual_machine" "vm" {
  for_each              = var.vm_details
  name                  = each.value.vm
  resource_group_name   = azurerm_resource_group.Flash1.name
  location              = azurerm_resource_group.Flash1.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  admin_password        = "Pa$$.word97"
  network_interface_ids = [azurerm_network_interface.nic1[each.key].id]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

}
