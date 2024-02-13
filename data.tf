data "azurerm_client_config" "current" {}

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

data "azurerm_key_vault_secrets" "existing_secrets" {
  key_vault_id = data.azurerm_key_vault.existing_keyvault.id
}

data "azurerm_key_vault_secret" "existing_secret" {
  count        = length(data.azurerm_key_vault_secrets.existing_secrets.secrets)
  name         = data.azurerm_key_vault_secrets.existing_secrets.names[count.index]
  key_vault_id = data.azurerm_key_vault.existing_keyvault.id
}

data "azurerm_key_vault_key" "existing_key" {
  count        = length(var.key_names)
  name         = var.key_names[count.index]
  key_vault_id = data.azurerm_key_vault.existing_keyvault.id
}

data "azurerm_app_configuration_keys" "existing_app_keys" {
  configuration_store_id = data.azurerm_app_configuration.existing_app_configuration.id
}

