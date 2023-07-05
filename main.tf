#IMPLEMENTING A SECURE NETWORK INFRASTRUCTURE USING TERRAFORM (AZURE)

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












