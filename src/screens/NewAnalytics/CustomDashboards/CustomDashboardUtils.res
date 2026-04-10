open LogicUtils

let parseWidget = (widgetJson: JSON.t): option<CustomDashboardTypes.widget> => {
  try {
    let wDict = widgetJson->getDictFromJsonObject
    let configDict = wDict->getDictfromDict("config")
    let posDict = wDict->getDictfromDict("position")

    let domain = configDict->getString("domain", "payments")
    let chartType = wDict->getString("chart_type", "line_chart")

    Some({
      widgetId: wDict->getString("widget_id", ""),
      widgetName: wDict->getString("widget_name", ""),
      chartType: switch chartType {
      | "bar_chart" => BarChart
      | "column_chart" => ColumnChart
      | "pie_chart" => PieChart
      | "stacked_bar_chart" => StackedBarChart
      | "sankey_chart" => SankeyChart
      | "funnel_chart" => FunnelChart
      | "table" => Table
      | "stat_number" => StatNumber
      | "gauge" => Gauge
      | _ => LineChart
      },
      position: {
        x: posDict->getInt("x", 0),
        y: posDict->getInt("y", 0),
        w: posDict->getInt("w", 12),
        h: posDict->getInt("h", 4),
      },
      config: {
        domain: switch domain {
        | "refunds" => Refunds
        | "disputes" => Disputes
        | "auth_events" => AuthEvents
        | "smart_retries" => SmartRetries
        | "routing" => Routing
        | _ => Payments
        },
        metrics: configDict->getStrArrayFromDict("metrics", []),
        groupBy: configDict->getStrArrayFromDict("group_by", []),
        filters: configDict->getJsonObjectFromDict("filters"),
        granularity: configDict->getOptionString("granularity"),
        timeRangePreset: configDict->getOptionString("time_range_preset"),
      },
    })
  } catch {
  | _ => None
  }
}

let parseDashboard = (json: JSON.t): option<CustomDashboardTypes.dashboard> => {
  try {
    let dict = json->getDictFromJsonObject
    let widgetsJson = dict->getArrayFromDict("widgets", [])

    let widgets =
      widgetsJson
      ->Array.filterMap(parseWidget)
      ->Array.toSorted((a, b) => float(a.position.y - b.position.y))

    Some({
      dashboardName: dict->getString("dashboard_name", ""),
      description: dict->getOptionString("description"),
      isDefault: dict->getBool("is_default", false),
      widgets,
      createdAt: dict->getString("created_at", ""),
      updatedAt: dict->getString("updated_at", ""),
    })
  } catch {
  | _ => None
  }
}

let parseDashboards = (response: JSON.t): array<CustomDashboardTypes.dashboard> => {
  response
  ->getArrayFromJson([])
  ->Array.get(0)
  ->Option.flatMap(json => {
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("CustomDashboards", [])
    ->Array.filterMap(parseDashboard)
    ->Some
  })
  ->Option.getOr([])
}

// Explicit widget serializer — avoids Identity.genericTypeToJson unsafe cast
let serializeWidget = (widget: CustomDashboardTypes.widget): JSON.t => {
  let config = Dict.fromArray([
    (
      "domain",
      (switch widget.config.domain {
      | Payments | SmartRetries => "payments"
      | Routing => "routing"
      | Refunds => "refunds"
      | Disputes => "disputes"
      | AuthEvents => "auth_events"
      })->JSON.Encode.string,
    ),
    ("metrics", widget.config.metrics->Array.map(JSON.Encode.string)->JSON.Encode.array),
    ("group_by", widget.config.groupBy->Array.map(JSON.Encode.string)->JSON.Encode.array),
    ("filters", widget.config.filters),
    (
      "granularity",
      switch widget.config.granularity {
      | Some(g) => g->JSON.Encode.string
      | None => JSON.Encode.null
      },
    ),
    (
      "time_range_preset",
      switch widget.config.timeRangePreset {
      | Some(t) => t->JSON.Encode.string
      | None => JSON.Encode.null
      },
    ),
  ])
  let position = Dict.fromArray([
    ("x", widget.position.x->JSON.Encode.int),
    ("y", widget.position.y->JSON.Encode.int),
    ("w", widget.position.w->JSON.Encode.int),
    ("h", widget.position.h->JSON.Encode.int),
  ])
  Dict.fromArray([
    ("widget_id", widget.widgetId->JSON.Encode.string),
    ("widget_name", widget.widgetName->JSON.Encode.string),
    ("chart_type", (widget.chartType :> string)->JSON.Encode.string),
    ("position", position->JSON.Encode.object),
    ("config", config->JSON.Encode.object),
  ])->JSON.Encode.object
}

let serializeWidgets = (widgets: array<CustomDashboardTypes.widget>): JSON.t => {
  widgets->Array.map(serializeWidget)->JSON.Encode.array
}

let buildOperationBody = (~operationType: string, ~data: JSON.t): JSON.t => {
  Dict.fromArray([
    (
      "CustomDashboards",
      Dict.fromArray([
        ("type", operationType->JSON.Encode.string),
        ("data", data),
      ])->JSON.Encode.object,
    ),
  ])->JSON.Encode.object
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
  | Table => "Table"
  | StatNumber => "Number"
  | Gauge => "Gauge"
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

let getDomainApiEntity = (
  domain: CustomDashboardTypes.analyticsDomain,
  ~metrics: array<string>=[],
) => {
  open APIUtilsTypes

  let hasPaymentIntentMetric = metrics->Array.some(WidgetConfiguratorUtils.isPaymentIntentMetric)

  switch domain {
  | Payments | SmartRetries | Routing =>
    hasPaymentIntentMetric ? V1(ANALYTICS_PAYMENTS_V2) : V1(ANALYTICS_PAYMENTS)
  | Refunds => V1(ANALYTICS_REFUNDS)
  | Disputes => V1(ANALYTICS_DISPUTES)
  | AuthEvents => V1(ANALYTICS_AUTHENTICATION_V2)
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

    switch diffMinutes {
    | m if m < 60 => `${m->Int.toString} min ago`
    | m if m < 1440 => `${(m / 60)->Int.toString} hours ago`
    | m => `${(m / 1440)->Int.toString} days ago`
    }
  } else {
    ""
  }
}

// Convert a metric string to its polyvariant safely (replaces Obj.magic)
let stringToMetric = (metricStr: string): option<InsightsTypes.metrics> => {
  switch metricStr {
  // Payment metrics - map to available polyvariants
  | "sessionized_payment_success_rate"
  | "sessionized_connector_success_rate" =>
    Some(#sessionized_payments_success_rate)
  | "sessionized_payment_processed_amount" => Some(#sessionized_payment_processed_amount)
  | "sessionized_payment_count"
  | "payment_count"
  | "sessionized_payment_intent_count"
  | "sessionized_payment_success_count"
  | "sessionized_avg_ticket_size"
  | "sessionized_retries_count" =>
    Some(#sessionized_payment_intent_count)
  | "payment_success_rate" => Some(#payment_success_rate)
  | "sessionized_smart_retried_amount" => Some(#sessionized_smart_retried_amount)
  // Refund metrics
  | "sessionized_refund_processed_amount" => Some(#sessionized_refund_processed_amount)
  | "sessionized_refund_count" => Some(#sessionized_refund_count)
  | "sessionized_refund_success_count" => Some(#sessionized_refund_success_count)
  | "sessionized_refund_success_rate" => Some(#sessionized_refund_success_rate)
  | "sessionized_refund_error_message" => Some(#sessionized_refund_error_message)
  | "sessionized_refund_reason" => Some(#sessionized_refund_reason)
  | "refund_processed_amount" => Some(#refund_processed_amount)
  // Dispute metrics
  | "dispute_status_metric" => Some(#dispute_status_metric)
  | "payments_distribution" => Some(#payments_distribution)
  | "failure_reasons" => Some(#failure_reasons)
  // Auth metrics
  | "authentication_count" => Some(#authentication_count)
  | "authentication_attempt_count" => Some(#authentication_attempt_count)
  | "authentication_success_count" => Some(#authentication_success_count)
  | "challenge_flow_count" => Some(#challenge_flow_count)
  | "frictionless_flow_count" => Some(#frictionless_flow_count)
  | "frictionless_success_count" => Some(#frictionless_success_count)
  | "challenge_attempt_count" => Some(#challenge_attempt_count)
  | "challenge_success_count" => Some(#challenge_success_count)
  | "authentication_funnel" => Some(#authentication_funnel)
  | "authentication_error_message" => Some(#authentication_error_message)
  | "authentication_exemption_approved_count" => Some(#authentication_exemption_approved_count)
  | "authentication_exemption_requested_count" => Some(#authentication_exemption_requested_count)
  | _ => None
  }
}

// Convert array of metric strings to polyvariants, filtering invalid ones
let metricsStringsToPolyvariants = (metricStrings: array<string>): array<InsightsTypes.metrics> => {
  metricStrings->Array.filterMap(stringToMetric)
}
