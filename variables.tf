# Name of existing resource group 

variable "existing_resource_group_name" {
  type        = string
  description = "Name of existing resource group"

  validation {
    condition     = var.existing_resource_group_name != null
    error_message = "Please provide a value for the existing_resource_group_name"
  }
}

# Name of new resource group where resources will be created

variable "new_resource_group_name" {
  type        = string
  description = "Name of new resource group where resources will be created"

  validation {
    condition     = var.new_resource_group_name != null
    error_message = "Please provide a value for the new_resource_group_name"
  }
}

# Name of new resource group where VNET will be created

variable "new_resource_group_name_for_vnet" {
  type        = string
  description = "Name of new resource group where VNET be created"

  validation {
    condition     = var.new_resource_group_name_for_vnet != null
    error_message = "Please provide a value for the new_resource_group_name_for_vnet"
  }
}

# Name of region where resources will reside

variable "region_name" {
  type        = string
  description = "Name of region where resources will reside"

  validation {
    condition     = var.region_name != null
    error_message = "Please provide a value for the region_name"
  }
}

# Name of existing key inside key vault

variable "key_names" {
  type        = list(string)
  description = "Name of existing key inside keyvault"

  validation {
    condition     = var.key_names != null
    error_message = "Please provide a value for the key_name"
  }
}