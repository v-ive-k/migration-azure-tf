
locals {
  subnet_ids = {
    internal = azurerm_subnet.internal.id
    wvd      = azurerm_subnet.wvd.id
    dmz      = azurerm_subnet.dmz.id
    bot_wvd  = azurerm_subnet.bot_wvd.id
  }
}

resource "azurerm_network_interface" "nic" {
  for_each            = var.nics
  name                = each.value.name
  location            = var.location_name
  resource_group_name = var.rg_name
  tags                = var.global_tags

  ip_configuration {
    name                          = coalesce(each.value.ip_config_name, "${each.value.name}-ipConfig")
    primary                       = true
    private_ip_address_allocation = each.value.allocation # "Dynamic" or "Static"
    private_ip_address            = each.value.allocation == "Static" ? each.value.private_ip : null
    private_ip_address_version    = "IPv4"
    subnet_id                     = local.subnet_ids[each.value.subnet_key]
  }

  lifecycle {
    ignore_changes = [
      accelerated_networking_enabled,
    ]
  }
}