# 引用现有的资源组
data "azurerm_resource_group" "existing_rg" {
  name = "terraformdemo-rg"  # 替换为你现有的资源组名称
}

resource "azurerm_route_table" "route_table_1" {
  name                = "UDR-Internet"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  route {
    name           = "to_internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = "Production"
  }
}