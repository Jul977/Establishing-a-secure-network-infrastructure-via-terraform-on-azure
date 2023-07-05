#Creating our virtual network
resource "azurerm_virtual_network" "net1" {
  name                = "Hub-vnet"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "dev"
  }

}

#Creating a subnet for our virtual machines (VM)
resource "azurerm_subnet" "net1" {
  name                 = "vm-snet"
  resource_group_name  = azurerm_resource_group.Flash1.name
  virtual_network_name = azurerm_virtual_network.net1.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Creating a dedicated subnet for our firewall
resource "azurerm_subnet" "net2" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.Flash1.name
  virtual_network_name = azurerm_virtual_network.net1.name
  address_prefixes     = ["10.0.2.0/24"]
}
#Creating a dedicated subnet for our bastion host
resource "azurerm_subnet" "net3" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.Flash1.name
  virtual_network_name = azurerm_virtual_network.net1.name
  address_prefixes     = ["10.0.3.0/24"]
}

