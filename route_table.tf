#Creating a route table to force traffic from our VM subnet to our firewall
resource "azurerm_route_table" "rt" {
  name                = "net1-routetable"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name

  route {
    name                   = "vm_snet-Julfirewall"
    address_prefix         = "10.0.1.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.2.4"
  }
}

resource "azurerm_subnet_route_table_association" "rta" {
  subnet_id      = azurerm_subnet.net1.id
  route_table_id = azurerm_route_table.rt.id
}









