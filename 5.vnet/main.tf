# 引用现有的资源组
data "azurerm_resource_group" "existing_rg" {
  name = "terraformdemo-rg"  # 替换为你现有的资源组名称
}


# 引用现有的安全组
data "azurerm_network_security_group" "azure_lb_nsg" {
  name                = "NIO_LB_Default"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}


# 引用现有的安全组
data "azurerm_network_security_group" "azure_vm_nsg" {
  name                = "NIO_VM_Default"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# 引用现有路由表
data "azurerm_route_table" "UDR-Internet" {
  name                = "UDR-Internet"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}



# EU Virtual Network
resource "azurerm_virtual_network" "eu_network" {
  name                = "NIO-EU"
  address_space       = ["10.99.0.0/16"]
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  subnet {
  name                 = "Prod-EU-AZURE-TOD-PAAS-K8S-POD-01"
  address_prefixes     = ["10.99.0.0/18"]
  }

  subnet {
  name                 = "PROD-EU-AZURE-TOD-PAAS-K8S-NODE-01"
  address_prefixes     = ["10.99.64.0/22"]
  }

  subnet {
  name                 = "PROD-EU-AZURE-TOD-FE-SLB-01"
  address_prefixes     = ["10.99.68.0/23"]
  }

  subnet {
  name                 = "PROD-EU-AZURE-TOD-FE-L7-LB-01"
  address_prefixes     = ["10.99.72.0/23"]
  #安全组
  security_group       = data.azurerm_network_security_group.azure_lb_nsg.id
  }

  subnet {
  name                 = "PROD-EU-AZURE-TOD-FE-VM-01"
  address_prefixes     = ["10.99.76.0/23"]
  #安全组
  security_group       = data.azurerm_network_security_group.azure_vm_nsg.id
  #路由表
  route_table_id       = data.azurerm_route_table.UDR-Internet.id
  }

  subnet {
  name                 = "PROD-EU-AZURE-TOD-BE-MYSQL-01"
  address_prefixes     = ["10.99.84.0/24"]
  }

  subnet {
  name                 = "PROD-EU-AZURE-TOD-BE-REDIS-01"
  address_prefixes     = ["10.99.85.0/24"]
  }
}




# EU OPS Virtual Network
resource "azurerm_virtual_network" "eu_ops_network" {
  name                = "NIO-EU-OPS"
  address_space       = ["10.88.224.0/20"]
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  subnet {
  name                 = "OPS-EU-AZURE-TOD-K8S-POD-01"
  address_prefixes     =  ["10.88.224.0/22"]
  }

  subnet {
  name                 = "OPS-EU-AZURE-TOD-K8S-NODE-01"
  address_prefixes     = ["10.88.228.0/24"]
  }

  subnet {
  name                 = "OPS-EU-AZURE-TOD-L4-LB-01"
  address_prefixes     = ["10.88.229.0/24"]
  }

  subnet {
  name                 = "OPS-EU-AZURE-TOD-L7-LB-01"
  address_prefixes     = ["10.88.231.0/24"]
  }

  subnet {
  name                 = "OPS-EU-AZURE-TOD-VM-01"
  address_prefixes     = ["10.88.233.0/24"]
  }

  subnet {
  name                 = "OPS-EU-AZURE-TOD-VM-02"
  address_prefixes     = ["10.88.234.0/24"]
  }
}
