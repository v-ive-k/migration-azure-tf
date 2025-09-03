
resource "azurerm_virtual_machine" "vm" {
  for_each              = var.vms
  name                  = each.value.name
  location              = var.location_name
  resource_group_name   = var.rg_name
  vm_size               = each.value.size
  network_interface_ids = [azurerm_network_interface.nic[each.value.nic_key].id]
  tags                  = var.global_tags

  delete_os_disk_on_termination    = false
  delete_data_disks_on_termination = false

  dynamic "boot_diagnostics" {
    for_each = each.value.boot_diag_uri != "" ? [1] : []
    content {
      enabled     = true
      storage_uri = each.value.boot_diag_uri
    }
  }

  dynamic "identity" {
    for_each = each.value.identity_type != "" ? [1] : []
    content {
      type = each.value.identity_type
    }
  }


  storage_os_disk {
    name              = var.os_disks[each.value.os_disk_key].name
    caching           = "ReadWrite"
    create_option     = each.value.os_disk_creation_option
    managed_disk_id   = each.value.os_disk_creation_option == "Attach" ? coalesce(lookup(each.value, "managed_disk_id", null), azurerm_managed_disk.os[each.value.os_disk_key].id) : null
    managed_disk_type = var.os_disks[each.value.os_disk_key].storage_account_type
    os_type           = var.os_disks[each.value.os_disk_key].os_type
    disk_size_gb      = var.os_disks[each.value.os_disk_key].disk_size_gb
  }

  # Image fields only when FromImage
  dynamic "storage_image_reference" {
    for_each = each.value.os_disk_creation_option == "FromImage" ? [1] : []
    content {
      id        = lookup(each.value.image_reference, "id", null)
      publisher = lookup(each.value.image_reference, "publisher", null)
      offer     = lookup(each.value.image_reference, "offer", null)
      sku       = lookup(each.value.image_reference, "sku", null)
      version   = lookup(each.value.image_reference, "version", null)
    }
  }

  dynamic "os_profile" {
    for_each = try(each.value.os_profiles, null) != null ? [each.value.os_profiles] : []
    content {
      computer_name  = lookup(os_profile.value, "computer_name", null)
      admin_username = os_profile.value.admin_username
      admin_password = each.value.os_disk_creation_option == "FromImage" ? (length(trimspace(lookup(os_profile.value, "admin_password", ""))) > 0 ? os_profile.value.admin_password : data.azurerm_key_vault_secret.ontadmin.value) : null
    }
  }

  dynamic "os_profile_windows_config" {
    for_each = try(each.value.windows_config, null) != null ? [each.value.windows_config] : []
    content {
      provision_vm_agent        = os_profile_windows_config.value.provision_vm_agent
      enable_automatic_upgrades = os_profile_windows_config.value.enable_automatic_upgrades
    }
  }

  dynamic "storage_data_disk" {
    for_each = lookup(var.data_disks, each.key, [])
    content {
      name              = storage_data_disk.value.name
      lun               = storage_data_disk.value.lun
      disk_size_gb      = storage_data_disk.value.disk_size_gb
      managed_disk_type = storage_data_disk.value.storage_account_type
      caching           = storage_data_disk.value.caching
      create_option     = "Attach"
      managed_disk_id   = azurerm_managed_disk.data["${each.key}-${storage_data_disk.value.lun}"].id
    }
  }

  lifecycle {
    ignore_changes = [
      boot_diagnostics,
      primary_network_interface_id,
      os_profile,
      os_profile_windows_config,
    ]
  }
}

# =====================================================================================
# ########## SQL MACHINES BLOCK ######### COMMENTED OUT FOR NOW ###########
# =====================================================================================
# resource "azurerm_managed_disk" "vm-sql-disks" {
#   for_each = {
#     for combo in flatten([
#       for sql_key, sql in var.sql_settings : [
#         for disk_key, disk in sql.data_disks : {
#           key         = "${sql_key}-${disk_key}"
#           server_name = sql.server_name
#           disk        = disk
#         }
#       ]
#     ]) : combo.key => combo
#   }

#   name                 = "${each.value.server_name}-disk-${each.value.disk.name}"
#   resource_group_name  = var.rg_name
#   location             = var.location_name
#   storage_account_type = each.value.disk.storage_account_type
#   create_option        = each.value.disk.create_option
#   disk_size_gb         = each.value.disk.disk_size_gb
#   tags                 = var.global_tags
# }


# # Attach SQL disks to VMs
# resource "azurerm_virtual_machine_data_disk_attachment" "vm-sql-disks-attach" {
#   for_each = {
#     for combo in flatten([
#       for sql_key, sql in var.sql_settings : [
#         for disk_key, disk in sql.data_disks : {
#           key         = "${sql_key}-${disk_key}"
#           server_name = sql.server_name
#           disk        = disk
#         }
#       ]
#     ]) : combo.key => combo
#   }

#   managed_disk_id    = azurerm_managed_disk.vm-sql-disks[each.key].id
#   virtual_machine_id = azurerm_virtual_machine.vm[each.value.server_name].id
#   lun                = each.value.disk.lun
#   caching            = each.value.disk.caching
# }

# # SQL server VM
# resource "azurerm_mssql_virtual_machine" "vm-sql" {
#   for_each = var.sql_settings

#   virtual_machine_id    = azurerm_virtual_machine.vm[each.value.server_name].id
#   sql_license_type      = each.value.sql_license_type
#   sql_connectivity_port = each.value.sql_connectivity_port
#   sql_connectivity_type = each.value.sql_connectivity_type

#   storage_configuration {
#     disk_type             = each.value.storage_disk_type
#     storage_workload_type = each.value.storage_workload_type
#     data_settings {
#       default_file_path = each.value.data_disks.data.default_file_path
#       luns              = [each.value.data_disks.data.lun]
#     }
#     dynamic "log_settings"  {
#       for_each = try([each.value.data_disk.logs], [])
#       content{
#       default_file_path = log_settings.value.default_file_path
#       luns              = [log_settings.value.logs.lun]
#     }
#     }
#     dynamic "temp_db_settings" {
#       for_each = try([each.value.data_disk.tempdb], [])
#       content{
#       default_file_path = temp_db_settings.value.default_file_path
#       luns              = [temp_db_settings.value.lun]
#     }
#   }
#   }

#   depends_on = [ 
#     azurerm_virtual_machine_data_disk_attachment.vm-sql-disks-attach 
#     ]
# }