#Creating an Internal load balancer to distribute traffic between the 5 VMs
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