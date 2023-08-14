# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.45.0"
    }
    databricks = {
      source = "databricks/databricks"
      version = "1.23.0"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}