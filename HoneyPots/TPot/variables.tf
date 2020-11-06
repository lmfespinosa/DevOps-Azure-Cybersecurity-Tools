provider "azurerm" {
  subscription_id        = var.subscription_id
  client_id              = var.client_id
  client_secret          = var.client_secret
  tenant_id              = var.tenant_id
  features{}
}

# Azure Credentials

variable "subscription_id" {default         = "subsID"}
variable "client_id" {default         = "clinetId"}
variable "client_secret" {default         = "clinetsecretId"}
variable "tenant_id" {default         = "tenantId"}

# vars

variable "location" { default  = "West Europe" }
variable "storage_account_name" {}
variable "container_name" { default = "vhds" }
variable "vm_name" { default = "TPot_VM" }
variable "os_name" { default = "Ubuntu_TPot" }
variable "vm_username" {default = "admin"}
variable "vm_password" {default = "admin"}
variable "vm_size" { default = "Basic_A1" }