#Global Var
variable "global_tags" {}

# Resource Group Variable
variable "rg_name" {}

# Locatoin Variable
variable "location_name" {}

# Main Networking Variables
variable "main_vnet_name" {}
variable "main_vnet_address_space" {}
variable "main_dns_servers" {}

# Subnet Variables
variable "internal_snet_name" {}
variable "internal_snet_address_prefix" {}
variable "wvd_snet_name" {}
variable "wvd_snet_address_prefix" {}
variable "dmz_snet_name" {}
variable "dmz_snet_address_prefix" {}
variable "bot_wvd_snet_name" {}
variable "bot_wvd_snet_address_prefix" {}

# Network Security Group Variables
variable "nsg_internal_name" {}
variable "nsg_wvd_name" {}
variable "nsg_dmz_name" {}
variable "nsg_bot_wvd_name" {}


# NICs Variables
variable "nics" {
  type = map(object({
    name : string
    subnet_key = optional(string)
    subnet_id : optional(string)
    allocation : string
    private_ip : string
    ip_config_name : optional(string)
    acclerated_networking_enabled : optional(bool)
    boot_diag_uri = optional(string, "")
    identity_type = optional(string, "")

  }))
}

variable "data_disks" {
  type = map(list(object({
    name                 = string
    disk_size_gb         = number
    storage_account_type = string
    lun                  = number
    caching              = string
  })))
  default = {}
}

# DISKs Variables
variable "os_disks" {
  type = map(object({
    name                 = string
    disk_size_gb         = number
    storage_account_type = string
    os_type              = string
    hyper_v_generation   = string

  }))
}

#VMs Variables
variable "vms" {
  type = map(object({
    name                    = string
    size                    = string
    nic_key                 = string
    os_disk_key             = string
    boot_diag_uri           = string
    identity_type           = string
    os_disk_creation_option = string
    managed_disk_id         = optional(string)

    #for image-based VM's
    image_reference = optional(object({
      id        = optional(string)
      offer     = optional(string)
      publisher = optional(string)
      sku       = optional(string)
      version   = optional(string)
    }))

    # Os Profiles
    os_profiles = optional(object({
      admin_username = string
      admin_password = optional(string)
      computer_name  = optional(string)
    }))

    # Windows config

    windows_config = optional(object({
      provision_vm_agent        = bool
      enable_automatic_upgrades = bool
    }))

    join_domain = optional(bool, false)
    ou_path     = optional(string)
  }))
}

# --- Key Vault + Domain (globals) ---
variable "kv_name" {}
variable "kv_rg" {}
variable "kv_secret_admin" { default = "ontadmin" }
variable "kv_secret_domain_join" { default = "svc-keaisjoin" }
variable "domain_name" {}
variable "domain_user_upn" { default = "svc-keaisjoin" }




# variable "sql_settings" {
#   type = map(object({
#     server_name           = string,
#     sql_license_type      = optional(string, "PAYG"),
#     sql_connectivity_port = optional(number, 1433),
#     sql_connectivity_type = optional(string, "PRIVATE"),
#     storage_disk_type     = optional(string, "NEW"),
#     storage_workload_type = optional(string, "GENERAL"),
#     data_disks = map(object({
#       name                 = string,
#       storage_account_type = string,
#       create_option        = string,
#       disk_size_gb         = number,
#       lun                  = number,
#       default_file_path    = string,
#       caching              = string,
#     })),
#   }))
# }