#Defining our variables
variable "vm_details" {
  type = map(object({
    nic = string
    vm  = string

  }))
  default = {
    "vm1" = {
      nic = "nic1"
      vm  = "vm1"
    }
    "vm2" = {
      nic = "nic2"
      vm  = "vm2"
    }
    "vm3" = {
      nic = "nic3"
      vm  = "vm3"
    }
  }
}

