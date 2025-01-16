# 引用现有的资源组
data "azurerm_resource_group" "existing_rg" {
  name = "terraformdemo-rg"  # 替换为你现有的资源组名称
}

resource "azurerm_storage_account" "example" {
  name                     = "mvjrwe7grd5s029g74nt3ilj"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}