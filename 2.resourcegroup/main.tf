resource "azurerm_resource_group" "rg" {
  name     = "terraformdemo-rg"
  location = "germanywestcentral"

  tags = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}


