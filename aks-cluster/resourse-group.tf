resource "azurerm_resource_group" "this" {
  name     = local.resourse_group_name
  location = local.region
}