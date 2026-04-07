open LogicUtils

let parseDashboard = (json: JSON.t): option<CustomDashboardTypes.dashboard> => {
  try {
    let dict = json->getDictFromJsonObject
    let widgetsJson = dict->getArrayFromDict("widgets", [])
    let widgets = widgetsJson->Array.filterMap(widgetJson => {
      try {
        let wDict = widgetJson->getDictFromJsonObject
        let configDict = wDict->getDictfromDict("config")
        let posDict = wDict->getDictfromDict("position")
        let config: CustomDashboardTypes.widgetConfig = {
          domain: configDict->getString("domain", "payments")->Obj.magic,
          metrics: configDict->getStrArrayFromDict("metrics", []),
          groupBy: configDict->getStrArrayFromDict("group_by", []),
          filters: configDict->getJsonObjectFromDict("filters"),
          granularity: configDict->getOptionString("granularity"),
          timeRangePreset: configDict->getOptionString("time_range_preset"),
        }
        let position: CustomDashboardTypes.widgetPosition = {
          x: posDict->getInt("x", 0),
          y: posDict->getInt("y", 0),
          w: posDict->getInt("w", 12),
          h: posDict->getInt("h", 4),
        }
        Some(
          (
            {
              widgetId: wDict->getString("widget_id", ""),
              widgetName: wDict->getString("widget_name", ""),
              chartType: wDict->getString("chart_type", "line_chart")->Obj.magic,
              position,
              config,
            }: CustomDashboardTypes.widget
          ),
        )
      } catch {
      | _ => None
      }
    })
    // Sort widgets by y position so saved order is preserved
    let sortedWidgets = widgets->Array.toSorted((a, b) => {
      let ay = (a: CustomDashboardTypes.widget).position.y
      let by = (b: CustomDashboardTypes.widget).position.y
      if ay < by {
        -1.0
      } else if ay > by {
        1.0
      } else {
        0.0
      }
    })
    Some(
      (
        {
          dashboardName: dict->getString("dashboard_name", ""),
          description: dict->getOptionString("description"),
          isDefault: dict->getBool("is_default", false),
          widgets: sortedWidgets,
          createdAt: dict->getString("created_at", ""),
          updatedAt: dict->getString("updated_at", ""),
        }: CustomDashboardTypes.dashboard
      ),
    )
  } catch {
  | _ => None
  }
}

let parseDashboards = (response: JSON.t): array<CustomDashboardTypes.dashboard> => {
  // Response is [ { "CustomDashboards": [...] } ] — an array wrapping one object
  let firstItem =
    response
    ->getArrayFromJson([])
    ->Array.get(0)
    ->Option.getOr(JSON.Encode.object(Dict.make()))
  firstItem
  ->getDictFromJsonObject
  ->getArrayFromDict("CustomDashboards", [])
  ->Array.filterMap(parseDashboard)
}

let buildOperationBody = (~operationType: string, ~data: JSON.t): JSON.t => {
  let inner = Dict.make()
  inner->Dict.set("type", operationType->JSON.Encode.string)
  inner->Dict.set("data", data)

  let outer = Dict.make()
  outer->Dict.set("CustomDashboards", inner->JSON.Encode.object)
  outer->JSON.Encode.object
}

let getChartTypeLabel = (chartType: CustomDashboardTypes.chartType) => {
  switch chartType {
  | LineChart => "Line Chart"
  | BarChart => "Bar Chart"
  | ColumnChart => "Column Chart"
  | PieChart => "Pie Chart"
  | StackedBarChart => "Stacked Bar"
  | SankeyChart => "Sankey"
  | FunnelChart => "Funnel"
  }
}

let getDomainLabel = (domain: CustomDashboardTypes.analyticsDomain) => {
  switch domain {
  | Payments => "Payments"
  | Refunds => "Refunds"
  | Disputes => "Disputes"
  | AuthEvents => "Authentication"
  | SmartRetries => "Smart Retries"
  | Routing => "Routing"
  }
}

let getDomainApiEntity = (domain: CustomDashboardTypes.analyticsDomain) => {
  open APIUtilsTypes
  switch domain {
  | Payments | SmartRetries => V1(ANALYTICS_PAYMENTS_V2)
  | Refunds => V1(ANALYTICS_REFUNDS)
  | Disputes => V1(ANALYTICS_DISPUTES)
  | AuthEvents => V1(ANALYTICS_AUTHENTICATION)
  | Routing => V1(ANALYTICS_PAYMENTS_V2)
  }
}

let getDomainString = (domain: CustomDashboardTypes.analyticsDomain) => {
  switch domain {
  | Payments | SmartRetries | Routing => "payments"
  | Refunds => "refunds"
  | Disputes => "disputes"
  | AuthEvents => "auth_events"
  }
}

let formatUpdatedAt = (updatedAt: string) => {
  if updatedAt->isNonEmptyString {
    let now = Date.make()->Date.toString->DayJs.getDayJsForString
    let updated = updatedAt->DayJs.getDayJsForString
    let diffMinutes = now.diff(updated.toString(), "minute")
    if diffMinutes < 60 {
      `${diffMinutes->Int.toString} min ago`
    } else if diffMinutes < 1440 {
      `${(diffMinutes / 60)->Int.toString} hours ago`
    } else {
      `${(diffMinutes / 1440)->Int.toString} days ago`
    }
  } else {
    ""
  }
}
