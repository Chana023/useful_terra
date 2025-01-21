terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terra_random_example" {
  name     = "example_terra_created"
  location = "SouthAfricaNorth"
}

output resource_group_id {
  value       = azurerm_resource_group.terra_random_example.id
}
