output "virtual_network_name" {
  description = "The name of the created virtual network."
  value       = azurerm_virtual_network.my_terraform_network.name
}
