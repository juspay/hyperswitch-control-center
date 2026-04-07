open CustomDashboardTypes

let maxDashboards = 10
let maxWidgetsPerDashboard = 20

let defaultWidgetPosition: widgetPosition = {x: 0, y: 0, w: 12, h: 4}
let halfWidgetPosition: widgetPosition = {x: 0, y: 0, w: 6, h: 4}

let paymentOverviewTemplate: array<widget> = [
  {
    widgetId: "template-1",
    widgetName: "Payment Success Rate",
    chartType: LineChart,
    position: {x: 0, y: 0, w: 6, h: 4},
    config: {
      domain: Payments,
      metrics: ["sessionized_payments_success_rate"],
      groupBy: [],
      filters: JSON.Encode.object(Dict.make()),
      granularity: Some("G_ONEDAY"),
      timeRangePreset: Some("last_30_days"),
    },
  },
  {
    widgetId: "template-2",
    widgetName: "Payment Method Distribution",
    chartType: PieChart,
    position: {x: 6, y: 0, w: 6, h: 4},
    config: {
      domain: Payments,
      metrics: ["sessionized_payment_intent_count"],
      groupBy: ["payment_method"],
      filters: JSON.Encode.object(Dict.make()),
      granularity: None,
      timeRangePreset: Some("last_7_days"),
    },
  },
  {
    widgetId: "template-3",
    widgetName: "Payments Processed",
    chartType: LineChart,
    position: {x: 0, y: 4, w: 12, h: 4},
    config: {
      domain: Payments,
      metrics: ["sessionized_payment_processed_amount"],
      groupBy: [],
      filters: JSON.Encode.object(Dict.make()),
      granularity: Some("G_ONEDAY"),
      timeRangePreset: Some("last_30_days"),
    },
  },
]

let connectorComparisonTemplate: array<widget> = [
  {
    widgetId: "template-1",
    widgetName: "Success Rate by Connector",
    chartType: LineChart,
    position: {x: 0, y: 0, w: 12, h: 4},
    config: {
      domain: Payments,
      metrics: ["sessionized_payments_success_rate"],
      groupBy: ["connector"],
      filters: JSON.Encode.object(Dict.make()),
      granularity: Some("G_ONEDAY"),
      timeRangePreset: Some("last_30_days"),
    },
  },
  {
    widgetId: "template-2",
    widgetName: "Volume by Connector",
    chartType: BarChart,
    position: {x: 0, y: 4, w: 6, h: 4},
    config: {
      domain: Payments,
      metrics: ["sessionized_payment_intent_count"],
      groupBy: ["connector"],
      filters: JSON.Encode.object(Dict.make()),
      granularity: None,
      timeRangePreset: Some("last_30_days"),
    },
  },
]

type templateOption = {
  label: string,
  description: string,
  widgets: array<widget>,
}

let templates: array<templateOption> = [
  {label: "Empty Dashboard", description: "Start from scratch", widgets: []},
  {
    label: "Payment Overview",
    description: "Success rate, volume, distribution",
    widgets: paymentOverviewTemplate,
  },
  {
    label: "Connector Comparison",
    description: "Compare PSP performance",
    widgets: connectorComparisonTemplate,
  },
]
