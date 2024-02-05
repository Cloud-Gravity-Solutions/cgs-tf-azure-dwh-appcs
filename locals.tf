locals {
  existing_action_group       = "ag-dlh-prod-001"
  existing_app_configuration  = "appcs-dlh-prod-westeu-001"
  existing_databricks_service = "dbw-dlh-prod-westeu-001"
  existing_keyvault           = "kvdlhprodwesteu001"
  existing_vnet               = "pdhl-vnet1-cwe"

  naming_convetions = {
    westeurope  = "westeu"
    northeurope = "northeu"

    vnet = {
      westeurope  = "cwe"
      northeurope = "cne"
    }
  }
}