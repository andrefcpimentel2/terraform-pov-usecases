output "tfe-beta" {
  value = {
    application_endpoint = azurerm_mysql_server.mysql_saas.fqdn

  }
}

