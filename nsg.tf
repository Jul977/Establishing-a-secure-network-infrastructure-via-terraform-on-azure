#Creating a Security rule to open port 3389 on our virtual machines
resource "azurerm_network_security_group" "net1" {
  name                = "FlashRule"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
}
resource "azurerm_network_security_rule" "example" {
  name                        = "Allow_port3389"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Flash1.name
  network_security_group_name = azurerm_network_security_group.net1.name
}

#Attaching our security rule to our VMs subnet
#This is also needed to allow communication between the VMs and our intenrnal load balancer since a standard load balancer is secure by default
resource "azurerm_subnet_network_security_group_association" "net1" {
  subnet_id                 = azurerm_subnet.net1.id
  network_security_group_id = azurerm_network_security_group.net1.id
}