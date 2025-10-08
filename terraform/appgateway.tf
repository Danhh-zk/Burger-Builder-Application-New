# Application Gateway (WAF_v2)

locals {
  frontend_privatelink_fqdn = replace(azurerm_linux_web_app.frontend.default_hostname, ".azurewebsites.net", ".privatelink.azurewebsites.net")
  backend_privatelink_fqdn  = replace(azurerm_linux_web_app.backend.default_hostname, ".azurewebsites.net", ".privatelink.azurewebsites.net")
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-appgw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}-appgw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_ip_configuration {
    name                 = "appGwFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "port80"
    port = 80
  }

  probe {
    name                                      = "frontend-probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  probe {
    name                                      = "backend-probe"
    protocol                                  = "Http"
    path                                      = "/api/health"
    interval                                  = 60
    timeout                                   = 60
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  backend_address_pool {
    name  = "frontendPool"
    fqdns = [local.frontend_privatelink_fqdn]
  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = [local.backend_privatelink_fqdn]
  }

  backend_http_settings {
    name                  = "frontendSetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "frontend-probe"
    host_name             = azurerm_linux_web_app.frontend.default_hostname
  }

  backend_http_settings {
    name                  = "backendSetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "backend-probe"
    host_name             = azurerm_linux_web_app.backend.default_hostname
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "appGwFrontendIP"
    frontend_port_name             = "port80"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "urlPathMap"
    default_backend_address_pool_name  = "frontendPool"
    default_backend_http_settings_name = "frontendSetting"

    path_rule {
      name                       = "apiRule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backendPool"
      backend_http_settings_name = "backendSetting"
    }
  }

  request_routing_rule {
    name               = "mainRule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener"
    url_path_map_name  = "urlPathMap"
    priority           = 100
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}
