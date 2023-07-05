#Creating a NAT gateway for our VM subnet.
#Since our VM was deployed without a public Ip and placed behind an internal load balancer the VMs would have no access to the internet by default
#NAT gateway gives our VM outbound connectivity to the internet

resource "azurerm_nat_gateway" "natg" {
  name                    = "Julnat-g"
  location                = azurerm_resource_group.Flash1.location
  resource_group_name     = azurerm_resource_group.Flash1.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "ngpipa" {
  nat_gateway_id      = azurerm_nat_gateway.natg.id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat-pip-prefix.id
}


#Attaching our NAT gateway to our VM subnet
resource "azurerm_subnet_nat_gateway_association" "ngsubnet" {
  subnet_id      = azurerm_subnet.net1.id
  nat_gateway_id = azurerm_nat_gateway.natg.id
} 