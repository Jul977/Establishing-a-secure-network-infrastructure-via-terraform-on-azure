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
    "vm4" = {
      nic = "nic4"
      vm  = "vm4"
    }
    "vm5" = {
      nic = "nic5"
      vm  = "vm5"
    }
  }
}

