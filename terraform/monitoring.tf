# App Gateway Alert
resource "azurerm_monitor_metric_alert" "app_gateway_backend_health" {
  name                = "appgw-backend-health-alert"
  resource_group_name = "pro-ftoon2-rg"
  scopes              = ["/subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/pro-ftoon2-rg/providers/Microsoft.Network/applicationGateways/g5-appgw"]
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

# Frontend App Alert
resource "azurerm_monitor_metric_alert" "frontend_requests" {
  name                = "fe-requests-alert"
  resource_group_name = "pro-ftoon2-rg"
  scopes              = ["/subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/pro-ftoon2-rg/providers/Microsoft.Web/sites/g5-frontend-app"]
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

# SQL DTU Alert
resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = "sql-dtu-alert"
  resource_group_name = "pro-ftoon2-rg"
  scopes              = ["/subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/pro-ftoon2-rg/providers/Microsoft.Sql/servers/g5-sql-server/databases/g5-sql-db"]
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
