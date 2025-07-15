
# 引用现有的资源组
data "azurerm_resource_group" "existing_rg" {
  name = "terraformdemo-rg"  # 替换为你现有的资源组名称
}

# 引用现有的虚拟网络
data "azurerm_virtual_network" "existing_vnet" {
  name                = "NIO-EU"  # 替换为你现有的 VNet 名称
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# 引用现有的子网
data "azurerm_subnet" "existing_subnet" {
  name                 = "PROD-EU-AZURE-TOD-BE-MYSQL-01"  # 替换为你现有的 Subnet 名称
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# 创建 MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "example_mysql_flexible_server" {
  name                = "leimysqlserver02"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  administrator_login          = "mysqladmin"
  administrator_password       = "P@ssw0rd1234!"
  version                      = "8.0.21"
  sku_name                     = "GP_Standard_D2ds_v4"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  zone                         = "1"   # 主节点在可用区1

  high_availability {
    mode                       = "ZoneRedundant"
    standby_availability_zone  = "3"  # 高可用节点在可用区3
  }

  storage {
    size_gb           = 20
    auto_grow_enabled = true
  }

  tags = {
    environment = "production"
  }
}

# 创建 MySQL Flexible Server 私有终结点
resource "azurerm_private_endpoint" "example_private_endpoint" {
  name                = "${azurerm_mysql_flexible_server.example_mysql_flexible_server.name}-pvt"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  subnet_id           = data.azurerm_subnet.existing_subnet.id

  private_service_connection {
    name                           = "${azurerm_mysql_flexible_server.example_mysql_flexible_server.name}-pvt-connection"
    private_connection_resource_id = azurerm_mysql_flexible_server.example_mysql_flexible_server.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }
}

# 创建私有 DNS 区域并关联到私有终结点
resource "azurerm_private_dns_zone" "example_dns_zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example_dns_zone_link" {
  name                  = "${azurerm_mysql_flexible_server.example_mysql_flexible_server.name}-pvt-link"
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.existing_vnet.id
}

resource "azurerm_private_dns_a_record" "example_a_record" {
  name                = "${azurerm_mysql_flexible_server.example_mysql_flexible_server.name}-record"
  zone_name           = azurerm_private_dns_zone.example_dns_zone.name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.example_private_endpoint.private_service_connection[0].private_ip_address]
}

output "mysql_flexible_server_fqdn" {
  value = azurerm_mysql_flexible_server.example_mysql_flexible_server.fqdn
}

output "mysql_flexible_server_administrator_login" {
  value = azurerm_mysql_flexible_server.example_mysql_flexible_server.administrator_login
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.example_private_endpoint.private_service_connection[0].private_ip_address
}