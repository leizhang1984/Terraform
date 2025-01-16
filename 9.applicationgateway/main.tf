
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
  name                 = "PROD-EU-AZURE-TOD-FE-L7-LB-01"  # 替换为你现有的 Subnet 名称
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# 创建一个新的公用 IP 地址
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  allocation_method   = "Static"
}


locals {
  backend_address_pool_name      = "${data.azurerm_virtual_network.existing_vnet.name}-beap"
  frontend_port_name             = "${data.azurerm_virtual_network.existing_vnet.name}-feport"
  frontend_ip_configuration_name = "${data.azurerm_virtual_network.existing_vnet.name}-feip"
  http_setting_name              = "${data.azurerm_virtual_network.existing_vnet.name}-be-htst"
  listener_name                  = "${data.azurerm_virtual_network.existing_vnet.name}-httplstn"
  request_routing_rule_name      = "${data.azurerm_virtual_network.existing_vnet.name}-rqrt"
  redirect_configuration_name    = "${data.azurerm_virtual_network.existing_vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "example_app_gateway" {
  name                = "example-appgateway"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }

  #Auto Scaling
  autoscale_configuration {
    min_capacity = 1
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.existing_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name                 = local.backend_address_pool_name
    fqdns                = ["www.baidu.com"]
    ip_addresses         = ["1.1.1.1","2.2.2.2"]
  }

  backend_address_pool {
    name                 = "Pool02"
    fqdns                = ["www.baidu.com"]
    ip_addresses         = ["1.1.1.1","3.3.3.3"]
  }


  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}


output "application_gateway_id" {
  value = azurerm_application_gateway.example_app_gateway.id
}