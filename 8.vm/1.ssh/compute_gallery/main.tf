# 引用现有的资源组
data "azurerm_resource_group" "existing_rg" {
  name = "sig-rg"  # 替换为你现有的资源组名称
}

# 引用现有的虚拟网络
data "azurerm_virtual_network" "existing_vnet" {
  name                = "NIO-EU"  # 替换为你现有的虚拟网络名称
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# 引用现有的子网
data "azurerm_subnet" "existing_subnet" {
  name                 = "PROD-EU-AZURE-TOD-FE-VM-01"  # 替换为你现有的子网名称
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# 引用现有的 Shared Image Gallery Image Version
data "azurerm_shared_image_version" "example_image_version" {
  gallery_name        = "nio_image_template_fk"  # 替换为你现有的 Image Gallery 名称
  image_name          = "centos8.2"  # 替换为你现有的 Image Definition 名称
  name                = "0.0.2"  # 替换为你现有的 Image Version 名称
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# 批量创建 3 台虚拟机
resource "azurerm_linux_virtual_machine" "example_vms" {
  count                           = var.vmcount
  name                            = "example-vm-${count.index + 1}"
  resource_group_name             = data.azurerm_resource_group.existing_rg.name
  location                        = data.azurerm_resource_group.existing_rg.location
  size                            = "Standard_D2s_v5"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/mnt/d/work/id_rsa.key")
  }

  network_interface_ids = [
    azurerm_network_interface.example_nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_shared_image_version.example_image_version.id

  zone = "1"  # 指定可用区
}

# 为每台虚拟机创建网络接口
resource "azurerm_network_interface" "example_nic" {
  count                = var.vmcount  # 从变量里获取
  name                 = "example-nic-${count.index + 1}"
  location             = data.azurerm_resource_group.existing_rg.location
  resource_group_name  = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 创建数据磁盘
resource "azurerm_managed_disk" "example_data_disk" {
  count                = var.vmcount  # 从变量里获取
  name                 = "example-vm-${count.index + 1}-datadisk"
  location             = data.azurerm_resource_group.existing_rg.location
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
  zone                 = 1
}

# 将每个数据盘挂载到对应的虚拟机上
resource "azurerm_virtual_machine_data_disk_attachment" "example_data_disk_attachment" {
  count                = var.vmcount  # 从变量里获取
  managed_disk_id      = azurerm_managed_disk.example_data_disk[count.index].id
  virtual_machine_id   = azurerm_linux_virtual_machine.example_vms[count.index].id
  lun                  = 0
  caching              = "ReadWrite"
}
