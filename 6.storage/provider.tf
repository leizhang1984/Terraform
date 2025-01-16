terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  /*
      backend "local" {
      path = "/mnt/d/work/github/terraform/terraform.tfstate"
    }
  */
}

provider "azurerm" {
  features {}
}