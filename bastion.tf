#Creating our bastion host
#Bastion allows us to securely manage our virtual machines
resource "azurerm_bastion_host" "bastion" {
  name                = "Julbastion"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "baconfig"
    subnet_id            = azurerm_subnet.net3.id
    public_ip_address_id = azurerm_public_ip.bastionip.id
  }
}