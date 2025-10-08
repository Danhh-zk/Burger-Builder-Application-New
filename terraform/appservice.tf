# App Service Plan

resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}


# Frontend Web App

resource "azurerm_linux_web_app" "frontend" {
  name                          = "${var.prefix}-frontend"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.plan.id
  public_network_access_enabled = false

  site_config {
    always_on                         = true
    health_check_path                 = "/"
    health_check_eviction_time_in_min = 5
    application_stack {
      docker_image_name   = "xdn73/frontend:v3"
      docker_registry_url = "https://index.docker.io"
    }
  }
  app_settings = {
    "VITE_API_BASE_URL" = "team5-backend.azurewebsites.net"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "frontend_vnet_integration" {
  app_service_id = azurerm_linux_web_app.frontend.id
  subnet_id      = azurerm_subnet.web.id
}

# Backend Web App

resource "azurerm_linux_web_app" "backend" {
  name                          = "${var.prefix}-backend"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.plan.id
  public_network_access_enabled = false

  site_config {
    always_on                         = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    application_stack {
      docker_image_name   = "xdn73/backend:v3"
      docker_registry_url = "https://index.docker.io"
    }
  }

  app_settings = {
    "SPRING_PROFILES_ACTIVE" = "azure"
    "DB_HOST"                = azurerm_mssql_server.sql.fully_qualified_domain_name
    "DB_NAME"                = azurerm_mssql_database.sqldb.name
    "DB_USERNAME"            = "team5admin"
    "DB_PASSWORD"            = "YourStrongP@ssword1"
  }

}

resource "azurerm_app_service_virtual_network_swift_connection" "backend_vnet_integration" {
  app_service_id = azurerm_linux_web_app.backend.id
  subnet_id      = azurerm_subnet.api.id
}
