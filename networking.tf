# Create Virtual Network -1
resource "azurerm_virtual_network" "main_vnet" {
  name                = var.main_vnet_name
  location            = var.location_name
  resource_group_name = var.rg_name
  address_space       = var.main_vnet_address_space
  dns_servers         = var.main_dns_servers
  tags                = var.global_tags
}

# Creating Subnets
resource "azurerm_subnet" "internal" {
  name                 = var.internal_snet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.main_vnet_name
  address_prefixes     = [var.internal_snet_address_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet" "wvd" {
  name                              = var.wvd_snet_name
  resource_group_name               = var.rg_name
  virtual_network_name              = var.main_vnet_name
  address_prefixes                  = [var.wvd_snet_address_prefix]
  private_endpoint_network_policies = "Enabled"
  service_endpoints                 = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet" "dmz" {
  name                              = var.dmz_snet_name
  resource_group_name               = var.rg_name
  virtual_network_name              = var.main_vnet_name
  address_prefixes                  = [var.dmz_snet_address_prefix]
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "bot_wvd" {
  name                 = var.bot_wvd_snet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.main_vnet_name
  address_prefixes     = [var.bot_wvd_snet_address_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}



# Network Security Groups
resource "azurerm_network_security_group" "nsg_internal" {
  name                = var.nsg_internal_name
  location            = var.location_name
  resource_group_name = var.rg_name
  tags                = var.global_tags
}

resource "azurerm_network_security_group" "nsg_wvd" {
  name                = var.nsg_wvd_name
  location            = var.location_name
  resource_group_name = var.rg_name
  tags                = var.global_tags
}

resource "azurerm_network_security_group" "nsg_dmz" {
  name                = var.nsg_dmz_name
  location            = var.location_name
  resource_group_name = var.rg_name
  tags                = var.global_tags
}

resource "azurerm_network_security_group" "nsg_bot_wvd" {
  name                = var.nsg_bot_wvd_name
  location            = var.location_name
  resource_group_name = var.rg_name
  tags                = var.global_tags
}

# Association NSG's to subnets
resource "azurerm_subnet_network_security_group_association" "assoc_internal" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.nsg_internal.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_wvd" {
  subnet_id                 = azurerm_subnet.wvd.id
  network_security_group_id = azurerm_network_security_group.nsg_wvd.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dmz" {
  subnet_id                 = azurerm_subnet.dmz.id
  network_security_group_id = azurerm_network_security_group.nsg_dmz.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_bot_wvd" {
  subnet_id                 = azurerm_subnet.bot_wvd.id
  network_security_group_id = azurerm_network_security_group.nsg_bot_wvd.id
}
