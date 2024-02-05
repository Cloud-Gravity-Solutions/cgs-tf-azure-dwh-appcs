data "azurerm_monitor_action_group" "existing_action_group" {
  resource_group_name = var.existing_resource_group_name
  name                = local.existing_action_group
}

data "azurerm_app_configuration" "existing_app_configuration" {
  name                = local.existing_app_configuration
  resource_group_name = var.existing_resource_group_name
}

data "azurerm_databricks_workspace" "existing_databricks_service" {
  name                = local.existing_databricks_service
  resource_group_name = var.existing_resource_group_name
}

data "azurerm_key_vault" "existing_keyvault" {
  name                = local.existing_keyvault
  resource_group_name = var.existing_resource_group_name
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = local.existing_vnet
  resource_group_name = var.new_resource_group_name_for_vnet
}