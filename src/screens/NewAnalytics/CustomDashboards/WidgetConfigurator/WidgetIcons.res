// Chart type and domain icons using the existing design system Icon component
// Icon choices follow the existing InsightsHelper patterns (graph-dark, table-view)

let getChartIcon = (chartType: CustomDashboardTypes.chartType, ~isActive: bool) => {
  let className = isActive ? "text-blue-600" : "text-gray-400"
  let name = switch chartType {
  | LineChart => "graph-dark"             // Same icon used in InsightsHelper.TabSwitch for graph view
  | BarChart => "chart-bar"               // FA horizontal bar chart icon
  | ColumnChart => "poll"                 // FA vertical bars of different heights
  | PieChart => "chart-pie"              // FA pie/donut circle
  | StackedBarChart => "nd-graph-chart-gantt" // ND stacked horizontal bars (Gantt-like)
  | FunnelChart => "funnel-dollar"        // FA funnel shape
  | SankeyChart => "sitemap"             // FA tree/flow connections
  | Table => "table-view"                // Same icon used in InsightsHelper.TabSwitch for table view
  | StatNumber => "hashtag"              // FA number/hash symbol
  | Gauge => "tachometer-alt"            // FA speedometer/gauge dial
  }
  <Icon name size=20 className />
}

let getDomainIcon = (domain: CustomDashboardTypes.analyticsDomain, ~isActive: bool) => {
  let className = isActive ? "text-blue-600" : "text-gray-400"
  let name = switch domain {
  | Payments => "nd-wallet"
  | SmartRetries => "nd-swap-arrow-horizontal"
  | Refunds => "refunds"
  | Disputes => "nd-flag"
  | AuthEvents => "nd-shield"
  | Routing => "nd-connectors"
  }
  <Icon name size=18 className />
}
