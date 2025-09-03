terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.10"
    }
  }
  backend "azurerm" {}
}
# Ont-dev1 provider block
provider "azurerm" {
  features {}
  subscription_id = "ffe5c17f-a5cd-46d5-8137-b8c02ee481af"
}
# Ont-prod1 provider block
provider "azurerm" {
  features {}
  alias           = "prod"
  subscription_id = "58e2361d-344c-4e85-b45b-c7435e9e2a42"
}