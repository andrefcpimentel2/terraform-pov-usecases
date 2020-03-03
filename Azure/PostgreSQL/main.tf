provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "postgresql_rg"
  location = "West Europe"
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "azurerm_postgresql_server" "example" {
  name                = "postgresqlexample-server-1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku_name = "B_Gen5_2"

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
    auto_grow             = "Enabled"
  }

  administrator_login          = "psqladminun"
  administrator_login_password = random_password.password.result
  version                      = "9.5"
  ssl_enforcement              = "Enabled"
}

resource "azurerm_postgresql_database" "example" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

output "postgresql_server_fqdn" {
  value = azurerm_postgresql_server.example.fqdn
}

output "postgresql_server_password" {
  value = random_password.password.result
}
