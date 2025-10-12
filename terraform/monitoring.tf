####################################################
# Metric Alerts - App Gateway, Frontend, SQL DTU
####################################################

# App Gateway Backend Health Alert
resource "azurerm_monitor_metric_alert" "app_gateway_backend_health" {
  name                = "appgw-backend-health-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_application_gateway.appgw.id]
  description         = "Alerts when the Application Gateway backend health drops below 100% for 5 minutes."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }
}

# Frontend Web App Requests Alert
resource "azurerm_monitor_metric_alert" "frontend_requests" {
  name                = "fe-requests-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.frontend.id]
  description         = "Alerts when frontend web app requests exceed threshold."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }
}

# SQL Database DTU Alert
resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = "sql-dtu-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_mssql_server.sql.id]
  description         = "Alerts when SQL DTU usage exceeds 80% for 5 minutes."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
