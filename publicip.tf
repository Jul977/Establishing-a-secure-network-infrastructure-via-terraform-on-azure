#Creating a public ip for our NAT gateway
resource "azurerm_public_ip" "nat-pip" {
  name                = "natg_pip"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_public_ip_prefix" "nat-pip-prefix" {
  name                = "natg_pip-prefix"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  prefix_length       = 31
  zones               = ["1"]
}

#Creating a public ip for our bastion host
resource "azurerm_public_ip" "bastionip" {
  name                = "bastionpip"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Creating a public ip for our firewall
resource "azurerm_public_ip" "pip" {
  name                = "fwpip"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}