type chartType =
  | @as("line_chart") LineChart
  | @as("bar_chart") BarChart
  | @as("column_chart") ColumnChart
  | @as("pie_chart") PieChart
  | @as("stacked_bar_chart") StackedBarChart
  | @as("sankey_chart") SankeyChart
  | @as("funnel_chart") FunnelChart
  | @as("table") Table
  | @as("stat_number") StatNumber
  | @as("gauge") Gauge

type analyticsDomain =
  | @as("payments") Payments
  | @as("refunds") Refunds
  | @as("disputes") Disputes
  | @as("auth_events") AuthEvents
  | @as("smart_retries") SmartRetries
  | @as("routing") Routing

type widgetPosition = {
  x: int,
  y: int,
  w: int,
  h: int,
}

type widgetConfig = {
  domain: analyticsDomain,
  metrics: array<string>,
  @as("group_by") groupBy: array<string>,
  filters: JSON.t,
  granularity: option<string>,
  @as("time_range_preset") timeRangePreset: option<string>,
}

type widget = {
  @as("widget_id") widgetId: string,
  @as("widget_name") widgetName: string,
  @as("chart_type") chartType: chartType,
  position: widgetPosition,
  config: widgetConfig,
}

type dashboard = {
  @as("dashboard_name") dashboardName: string,
  description: option<string>,
  @as("is_default") isDefault: bool,
  widgets: array<widget>,
  @as("created_at") createdAt: string,
  @as("updated_at") updatedAt: string,
}

type dashboardViewMode = View | Edit

type subView = DashboardListView | DashboardCanvasView(dashboard)
