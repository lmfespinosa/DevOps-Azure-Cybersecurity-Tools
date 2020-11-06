resource "azurerm_storage_account" "jenkins_storage" {
  name 			= var.storage_account_name
  resource_group_name 	= azurerm_resource_group.myterraformgroup.name
  location 		= var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "jenkins_cont" {
  name 			= var.container_name
  storage_account_name 	= azurerm_storage_account.jenkins_storage.name
  container_access_type = "private"
}