locals {
  vms_to_join = {
    for k, v in var.vms :
    k => v if try(v.join_domain, false) && length(trimspace(try(v.ou_path, ""))) > 0
  }
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  for_each                   = local.vms_to_join
  name                       = "${each.key}-domain-join"
  virtual_machine_id         = azurerm_virtual_machine.vm[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = each.value.ou_path
    User    = "${var.domain_user_upn}@${var.domain_name}"
    Restart = "true"
    Options = 3
  })

  protected_settings = jsonencode({
    Password = data.azurerm_key_vault_secret.svc_keaisjoin.value
  })

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [azurerm_virtual_machine.vm]
}