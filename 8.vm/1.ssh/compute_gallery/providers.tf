terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "166157a8-9ce9-400b-91c7-1d42482b83d6"
}
