data "azurerm_key_vault" "it" {
  provider            = azurerm.prod
  name                = var.kv_name
  resource_group_name = var.kv_rg
}

data "azurerm_key_vault_secret" "ontadmin" {
  provider     = azurerm.prod
  name         = var.kv_secret_admin
  key_vault_id = data.azurerm_key_vault.it.id
}

data "azurerm_key_vault_secret" "svc_keaisjoin" {
  provider     = azurerm.prod
  name         = var.kv_secret_domain_join
  key_vault_id = data.azurerm_key_vault.it.id
}