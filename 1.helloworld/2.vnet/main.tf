resource "azurerm_resource_group" "rg" {
  name     = "terraformdemo-rg"
  location = "westus2"

  tags = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}



# Create a virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16","10.1.0.0/16"]
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
}

#terraform import azurerm_resource_group.rg "/subscriptions/166157a8-9ce9-400b-91c7-1d42482b83d6/resourceGroups/terraformdemo-rg" 
#terraform import azurerm_virtual_network.my_terraform_network "/subscriptions/166157a8-9ce9-400b-91c7-1d42482b83d6/resourceGroups/terraformdemo-rg/providers/Microsoft.Network/virtualNetworks/myvnet"