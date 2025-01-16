
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
  name                 = "PROD-EU-AZURE-TOD-BE-REDIS-01"  # 替换为你现有的 Subnet 名称
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# 创建 Redis Cache
resource "azurerm_redis_cache" "example_redis_cache" {
  name                = "leizhangredis01"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
}

# 创建 Redis Cache 私有终结点
resource "azurerm_private_endpoint" "example_private_endpoint" {
  name                = "example-private-endpoint"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  subnet_id           = data.azurerm_subnet.existing_subnet.id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_redis_cache.example_redis_cache.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }
}

# 创建私有 DNS 区域并关联到私有终结点
resource "azurerm_private_dns_zone" "example_dns_zone" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example_dns_zone_link" {
  name                  = "example-dns-zone-link"
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.existing_vnet.id
}

resource "azurerm_private_dns_a_record" "example_a_record" {
  name                = "example-redis-cache"
  zone_name           = azurerm_private_dns_zone.example_dns_zone.name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.example_private_endpoint.private_service_connection[0].private_ip_address]
}

output "redis_cache_hostname" {
  value = azurerm_redis_cache.example_redis_cache.hostname
}


output "private_endpoint_ip" {
  value = azurerm_private_endpoint.example_private_endpoint.private_service_connection[0].private_ip_address
}