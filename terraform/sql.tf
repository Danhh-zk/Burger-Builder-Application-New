# Azure SQL (Private)

resource "azurerm_mssql_server" "sql" {
  name                          = "${var.prefix}-sqlserver"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = "team5admin"
  administrator_login_password  = "YourStrongP@ssword1"
  public_network_access_enabled = true
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "${var.prefix}-sqldb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}
# add firewall
resource "azurerm_mssql_firewall_rule" "db_firewall" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "10.0.2.0"
  end_ip_address   = "10.0.2.255"
}

resource "azurerm_mssql_firewall_rule" "db_firewall2" {
  name             = "FirewallRule2"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "20.119.136.0"
  end_ip_address   = "20.119.136.17"
}

# Private Endpoint + DNS for SQL

resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_vnet_link" {
  name                  = "sql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.prefix}-sql-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns_zone.id]
  }
}
