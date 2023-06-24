#IMPLEMENTING A SECURE NETWORK INFRASTRUCTURE USING TERRAFORM (AZURE)

#This code creates 3 Virtual machine(VM) with IIS installed using custom script extension. 
#The VMs are loadbalanced by a standard internal lodabalacer and secured by azure firewall
#An azure bastion host is deployed to securely access the VMs privately.
#A NAT gateway is deployed to provide outbound internet connectivity to the VMs because the VMs were deployed without a public ip and placed behind a standard internal loadbalancer
#Users can securely access the server using the public IP of the firewall on port 80
#A remote backend which implements state locking was used to configure our state file. 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Instructing terraform to use the remote backend for our state file
# Comment this block of code if a remote backend is not configured
terraform {
  backend "azurerm" {
    resource_group_name  = "tf-rg-statefile"
    storage_account_name = "jultfstorage"
    container_name       = "jultfstate"
    key                  = "terraform.tfstate"
  }
}


provider "azurerm" {
  features {}
}

#Creating our resource group
resource "azurerm_resource_group" "Flash1" {
  name     = "FlashRg"
  location = "East Us"
  tags = {
    environment = "dev"
  }
}

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

#Creating 3 network interface for our VMs
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
#Creating 3 VMs (Windows server)
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

#Installing IIS on each VMs using custom scripts
resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  for_each                   = var.vm_details
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeManagementTools"
    }
SETTINGS
}

#Creating an Internal load balancer to distribute traffic between the 3 VMs
resource "azurerm_lb" "lb" {
  name                = "JulLb"
  location            = azurerm_resource_group.Flash1.location
  resource_group_name = azurerm_resource_group.Flash1.name
  sku                 = "Standard"


  frontend_ip_configuration {
    name                          = "PrivateLb"
    subnet_id                     = azurerm_subnet.net1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.1.10"

  }
}

resource "azurerm_lb_backend_address_pool" "Pool1" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "VmPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "bepa1" {
  for_each                = var.vm_details
  network_interface_id    = azurerm_network_interface.nic1[each.key].id
  ip_configuration_name   = "${each.value.nic}-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Pool1.id
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "vm-probe"
  port            = 80
}

#Creating a load balacncing rule to probe the IIS server on port 80 since IIS listens on port 80 by default
resource "azurerm_lb_rule" "rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "Lbrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PrivateLb"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.Pool1.id]
}

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

#Creating a rule to port forward traffic from our firewall to our internal loadbalancer
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