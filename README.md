IMPLEMENTING A SECURE NETWORK INFRASTRUCTURE USING TERRAFORM (AZURE)

#This code creates 3 Virtual machine(VM) with IIS installed using custom script extension. 
#The VMs are loadbalanced by a standard internal lodabalacer and secured by azure firewall
#An azure bastion host is deployed to securely access the VMs privately.
#A NAT gateway is deployed to provide outbound internet connectivity to the VMs because the VMs were deployed without a public ip 
#Users can access the server using the public IP of the firewall on port 80
#A remote backend which implements state locking was used to configure our state file. 

