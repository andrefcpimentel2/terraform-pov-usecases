resource "azurerm_resource_group" "dbsaasrg" {
  name     = var.az_resourcegroup_name
  location = var.az_resourcegroup_region
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "azurerm_mysql_server" "mysql_saas" {
  name                = "mysql-saasdb"
  location            = azurerm_resource_group.dbsaasrg.location
  resource_group_name = azurerm_resource_group.dbsaasrg.name

  sku {
    name     = "B_Gen5_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.sql_server_admin_login
  administrator_login_password = random_password.password.result
  version                      = "5.7"
  ssl_enforcement              = "Enabled"
}

resource "azurerm_mysql_database" "example" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.dbsaasrg.name
  server_name         = azurerm_mysql_server.mysql_saas.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}