resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "westus2"

  tags = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}



# Create a virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}
