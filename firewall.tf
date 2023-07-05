#Creating our firewall to secure our traffic
resource "azurerm_firewall" "fw" {
  name                = "Julfirewall"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.policy.id

  ip_configuration {
    name                 = "fwconfig"
    subnet_id            = azurerm_subnet.net2.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

#Creating our firewall policy to manage our firewall rules
resource "azurerm_firewall_policy" "policy" {
  name                = "Julpolicy"
  resource_group_name = azurerm_resource_group.Flash1.name
  location            = azurerm_resource_group.Flash1.location
}

#Creating a rule(DNAT) to translate the public Ip of the firewall to that of our internal loadbalancer
resource "azurerm_firewall_policy_rule_collection_group" "rcg" {
  name               = "Dnat-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 200

  nat_rule_collection {
    name     = "dnat_rule_collection1"
    priority = 200
    action   = "Dnat"
    rule {
      name                = "nat_rule_collection1_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.pip.ip_address
      destination_ports   = ["80"]
      translated_address  = "10.0.1.10"
      translated_port     = "80"
    }
  }

}