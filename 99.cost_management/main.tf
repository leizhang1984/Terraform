resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                = "leiexample001"
  resource_group_name = azurerm_resource_group.example.name

  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                 = "examplecontainer"
  storage_account_name = azurerm_storage_account.example.name
}

resource "azurerm_resource_group_cost_management_export" "example" {
  name                         = "example"
  resource_group_id            = azurerm_resource_group.example.id
  recurrence_type              = "Daily"
  recurrence_period_start_date = "2024-09-30T00:00:00Z"
  recurrence_period_end_date   = "2024-10-30T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.example.resource_manager_id
    root_folder_path = "/root/updated"
  }

  export_data_options {
    type       = "ActualCost"
    time_frame = "WeekToDate"
  }
}