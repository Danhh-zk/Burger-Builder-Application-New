# Private DNS for App Services + Private Endpoints

resource "azurerm_private_dns_zone" "appservice_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "appservice_dns_vnet_link" {
  name                  = "appservice-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.appservice_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_private_endpoint" "frontend_pe" {
  name                = "${var.prefix}-frontend-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "frontend-connection"
    private_connection_resource_id = azurerm_linux_web_app.frontend.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "frontend-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.appservice_dns_zone.id]
  }
}

resource "azurerm_private_endpoint" "backend_pe" {
  name                = "${var.prefix}-backend-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "backend-connection"
    private_connection_resource_id = azurerm_linux_web_app.backend.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "backend-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.appservice_dns_zone.id]
  }
}
