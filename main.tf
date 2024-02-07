# New Resource group where resources will be created

resource "azurerm_resource_group" "new_resource_group" {
  name     = var.new_resource_group_name
  location = var.region_name
}

# New resource group where the VNET will reside

resource "azurerm_resource_group" "new_resource_group_VNET" {
  name     = var.new_resource_group_name_for_vnet
  location = var.region_name
}

# Azure Key Vault that will be created on new resource group

resource "azurerm_key_vault" "new_key_vault" {
  name                          = join("", ["kvdlhprod", local.naming_convetions[azurerm_resource_group.new_resource_group_VNET.location], "001"])
  location                      = azurerm_resource_group.new_resource_group.location
  resource_group_name           = azurerm_resource_group.new_resource_group.name
  enabled_for_disk_encryption   = data.azurerm_key_vault.existing_keyvault.enabled_for_disk_encryption
  tenant_id                     = data.azurerm_key_vault.existing_keyvault.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = data.azurerm_key_vault.existing_keyvault.purge_protection_enabled
  public_network_access_enabled = data.azurerm_key_vault.existing_keyvault.public_network_access_enabled
  sku_name                      = data.azurerm_key_vault.existing_keyvault.sku_name
  enable_rbac_authorization     = data.azurerm_key_vault.existing_keyvault.enable_rbac_authorization

  dynamic "access_policy" {
    for_each = try(data.azurerm_key_vault.existing_keyvault.access_policy, [])

    content {
      application_id          = lookup(access_policy.value, "application_id", null)
      tenant_id               = lookup(access_policy.value, "tenant_id", null)
      object_id               = lookup(access_policy.value, "object_id", null)
      key_permissions         = lookup(access_policy.value, "key_permissions", null)
      secret_permissions      = lookup(access_policy.value, "secret_permissions", null)
      storage_permissions     = lookup(access_policy.value, "storage_permissions", null)
      certificate_permissions = lookup(access_policy.value, "certificate_permissions", null)
    }
  }

  dynamic "network_acls" {
    for_each = try(data.azurerm_key_vault.existing_keyvault.network_acls, [])

    content {
      bypass                     = lookup(network_acls.value, "bypass", null)
      default_action             = lookup(network_acls.value, "default_action", null)
      ip_rules                   = lookup(network_acls.value, "ip_rules", null)
      virtual_network_subnet_ids = lookup(network_acls.value, "virtual_network_subnet_ids", null)
    }
  }

  tags = data.azurerm_key_vault.existing_keyvault.tags
}

# Azure Key Vault Secret to be added to the new Keyvault

resource "azurerm_key_vault_secret" "new_secrets" {
  count        = length(data.azurerm_key_vault_secrets.existing_secrets.secrets)
  name         = data.azurerm_key_vault_secret.existing_secret[count.index].name
  value        = data.azurerm_key_vault_secret.existing_secret[count.index].value
  key_vault_id = azurerm_key_vault.new_key_vault.id
}

# Azure App Configuration that will be created on new resource group

resource "azurerm_app_configuration" "new_app_configuration" {
  name                       = join("-", ["appcs", "dlh", "prod", local.naming_convetions[azurerm_resource_group.new_resource_group_VNET.location], "001"])
  resource_group_name        = azurerm_resource_group.new_resource_group.name
  location                   = azurerm_resource_group.new_resource_group.location
  sku                        = data.azurerm_app_configuration.existing_app_configuration.sku
  local_auth_enabled         = data.azurerm_app_configuration.existing_app_configuration.local_auth_enabled
  purge_protection_enabled   = data.azurerm_app_configuration.existing_app_configuration.purge_protection_enabled
  soft_delete_retention_days = data.azurerm_app_configuration.existing_app_configuration.sku == "standard" ? data.azurerm_app_configuration.existing_app_configuration.soft_delete_retention_days : null

  dynamic "identity" {
    for_each = try(data.azurerm_app_configuration.existing_app_configuration.identity, [])

    content {
      type         = lookup(encryption.value, "type", null)
      identity_ids = lookup(encryption.value, "identity_ids", null)
    }
  }

  dynamic "encryption" {
    for_each = try(data.azurerm_app_configuration.existing_app_configuration.encryption, [])

    content {
      key_vault_key_identifier = lookup(encryption.value, "key_vault_key_identifier", null)
      identity_client_id       = lookup(encryption.value, "identity_client_id", null)
    }
  }

  dynamic "replica" {
    for_each = try(data.azurerm_app_configuration.existing_app_configuration.replica, [])

    content {
      name     = join("-", [data.azurerm_app_configuration.existing_app_configuration.name, "replica"])
      location = azurerm_resource_group.new_resource_group.location
    }
  }

  tags = data.azurerm_app_configuration.existing_app_configuration.tags

  depends_on = [azurerm_key_vault.new_key_vault]

}

# Azure Databricks Service to be created on the new resource group

resource "azurerm_databricks_workspace" "new_databricks_service" {
  name                = join("-", ["dbw", "dlh", "prod", local.naming_convetions[azurerm_resource_group.new_resource_group_VNET.location], "001"])
  resource_group_name = azurerm_resource_group.new_resource_group.name
  location            = azurerm_resource_group.new_resource_group.location
  sku                 = data.azurerm_databricks_workspace.existing_databricks_service.sku


  tags = data.azurerm_databricks_workspace.existing_databricks_service.tags
}


# Azure Action Group to be created on new resource group

resource "azurerm_monitor_action_group" "new_action_group" {
  name                = data.azurerm_monitor_action_group.existing_action_group.name
  resource_group_name = azurerm_resource_group.new_resource_group.name
  short_name          = data.azurerm_monitor_action_group.existing_action_group.short_name


  dynamic "arm_role_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.arm_role_receiver, [])

    content {
      name                    = lookup(arm_role_receiver.value, "name", null)
      role_id                 = lookup(arm_role_receiver.value, "role_id", null)
      use_common_alert_schema = lookup(arm_role_receiver.value, "use_common_alert_schema", null)
    }
  }

  dynamic "automation_runbook_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.automation_runbook_receiver, [])

    content {
      name                    = lookup(automation_runbook_receiver.value, "name", null)
      automation_account_id   = lookup(automation_runbook_receiver.value, "automation_account_id", null)
      runbook_name            = lookup(automation_runbook_receiver.value, "runbook_name", null)
      webhook_resource_id     = lookup(automation_runbook_receiver.value, "webhook_resource_id", null)
      is_global_runbook       = lookup(automation_runbook_receiver.value, "is_global_runbook", null)
      service_uri             = lookup(automation_runbook_receiver.value, "service_uri", null)
      use_common_alert_schema = lookup(automation_runbook_receiver.value, "use_common_alert_schema", null)
    }
  }

  dynamic "azure_app_push_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.azure_app_push_receiver, [])

    content {
      name          = lookup(azure_app_push_receiver.value, "name", null)
      email_address = lookup(azure_app_push_receiver.value, "email_address", null)
    }
  }


  dynamic "azure_function_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.azure_function_receiver, [])

    content {
      name                     = lookup(azure_function_receiver.value, "name", null)
      function_app_resource_id = lookup(azure_function_receiver.value, "function_app_resource_id", null)
      function_name            = lookup(azure_function_receiver.value, "function_name", null)
      http_trigger_url         = lookup(azure_function_receiver.value, "http_trigger_url", null)
      use_common_alert_schema  = lookup(azure_function_receiver.value, "use_common_alert_schema", null)
    }
  }

  dynamic "email_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.email_receiver, [])

    content {
      name          = lookup(email_receiver.value, "name", null)
      email_address = lookup(email_receiver.value, "email_address", null)
    }
  }

  dynamic "event_hub_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.event_hub_receiver, [])

    content {
      name                    = lookup(event_hub_receiver.value, "name", null)
      event_hub_namespace     = lookup(event_hub_receiver.value, "event_hub_namespace", null)
      event_hub_name          = lookup(event_hub_receiver.value, "event_hub_name", null)
      subscription_id         = lookup(event_hub_receiver.value, "subscription_id", null)
      use_common_alert_schema = lookup(event_hub_receiver.value, "use_common_alert_schema", null)
    }
  }

  dynamic "itsm_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.itsm_receiver, [])

    content {
      name                 = lookup(itsm_receiver.value, "name", null)
      workspace_id         = lookup(itsm_receiver.value, "workspace_id", null)
      connection_id        = lookup(itsm_receiver.value, "connection_id", null)
      ticket_configuration = lookup(itsm_receiver.value, "ticket_configuration", null)
      region               = lookup(itsm_receiver.value, "region", null)
    }
  }

  dynamic "logic_app_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.logic_app_receiver, [])

    content {
      name                    = lookup(logic_app_receiver.value, "name", null)
      resource_id             = lookup(logic_app_receiver.value, "resource_id", null)
      callback_url            = lookup(logic_app_receiver.value, "callback_url", null)
      use_common_alert_schema = lookup(logic_app_receiver.value, "use_common_alert_schema", null)
    }
  }

  dynamic "sms_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.sms_receiver, [])

    content {
      name         = lookup(sms_receiver.value, "name", null)
      country_code = lookup(sms_receiver.value, "country_code", null)
      phone_number = lookup(sms_receiver.value, "phone_number", null)
    }
  }

  dynamic "voice_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.voice_receiver, [])

    content {
      name         = lookup(voice_receiver.value, "name", null)
      country_code = lookup(voice_receiver.value, "country_code", null)
      phone_number = lookup(voice_receiver.value, "phone_number", null)
    }
  }

  dynamic "webhook_receiver" {
    for_each = try(data.azurerm_monitor_action_group.existing_action_group.webhook_receiver, [])

    content {
      name                    = lookup(webhook_receiver.value, "name", null)
      service_uri             = lookup(webhook_receiver.value, "service_uri", null)
      use_common_alert_schema = lookup(webhook_receiver.value, "use_common_alert_schema", null)
    }
  }

}

# Azure VNET that will be replicated

resource "azurerm_virtual_network" "new_vnet" {
  name                = join("-", ["pdlh", "vnet1", local.naming_convetions.vnet[azurerm_resource_group.new_resource_group_VNET.location]])
  location            = azurerm_resource_group.new_resource_group_VNET.location
  resource_group_name = azurerm_resource_group.new_resource_group_VNET.name
  address_space       = ["10.45.0.0/16"]
}