1. 1st Project Cloud Gravity Solutions

# Terraform Module: Resource Replication

This Terraform module provisions the same infrastructure, from an existing one in a new resource group in another location. 

## Authors
- [Marko Skendo](https://github.com/ingmarko)
- [Ditmir Spahiu](https://github.com/DitmirSpahiu)

## List of Replicated Resources

1- Azure Databricks Service


2- Azure App Configuration


3- Key Vault


4- Azure Monitor Action Group


5- Azure Virtual Network 

## How to Use

### Variables

| Name                           | Description                                                                                   | Type        | Default                             | Required |
|--------------------------------|-----------------------------------------------------------------------------------------------|:-----------:|:-----------------------------------:|:-------:|
| `existing_resource_group_name` | Name of the existing resource group to use for fetching data.                                 | `string`    | n/a                                 | yes     |
| `new_resource_group_name`      | Name of the new resource group where resources will be created.                                | `string`    | n/a                                 | yes     |
| `new_resource_group_name_for_vnet`      | Name of the new virtual network that will be created.                                | `string`    | n/a                                 | yes     |
| `region_name`                  | Name of the region where resources will reside.                                               | `string`    | n/a                                 | yes     |

### Example with ALL Variables:

```hcl
module "replication" {
  source                                = "path/to/module_files"
  existing_resource_group_name          = "existing-rg-name"
  new_resource_group_name               = "new-rg-name"
  new_resource_group_name_for_vnet      = "test-vnet-2"
  region_name                           = "your-region-name" 
}
