resource "azurerm_monitor_metric_alert" "app_gateway_backend_health" {
  name                = "appgw-backend-health-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = ["/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.Network/applicationGateways/YOUR_APP_GATEWAY"] # استبدلي بالـ ID الفعلي
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

resource "azurerm_monitor_metric_alert" "frontend_requests" {
  name                = "fe-requests-alert"
  resource_group_name = "YOUR_RESOURCE_GROUP"
  scopes              = ["/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.Web/sites/YOUR_WEB_APP"] # استبدلي بالـ ID الفعلي
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

resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = "sql-dtu-alert"
  resource_group_name = "YOUR_RESOURCE_GROUP"
  scopes              = ["/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.Sql/servers/YOUR_SQL_SERVER/databases/YOUR_DATABASE"] # استبدلي بالـ ID الفعلي
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
