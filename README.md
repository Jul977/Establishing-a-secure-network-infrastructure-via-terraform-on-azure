# Establishing a secure network infrastructure via terraform on azure

* This script facilitates the creation of five Virtual Machines (VMs), each integrating IIS through a custom script extension.

* The VMs are subject to load balancing via a conventional internal load balancer and their security is fortified by an Azure Firewall.

* To ensure confidential VM access, an Azure Bastion host is deployed.

* In anticipation of potential SNAT port exhaustion affecting our firewall, a NAT gateway is implemented, guaranteeing outbound internet connectivity for the VMs.

* End users are granted access to the server by utilizing the firewall's public IP on port 80.

* A remote backend, which incorporates state locking mechanisms, is employed to configure our state file.

* Resources deployed: Virtual network, Network Security Group, Public IP, Route table, Azure bastion, Azure load balancer, Azure firewall, NAT gateway 

