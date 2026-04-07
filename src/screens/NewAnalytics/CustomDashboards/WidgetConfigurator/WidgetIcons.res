// Uniform SVG icons for the widget configurator
// All use stroke-based rendering with consistent weight and color

let lineChart = (~color: string) =>
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <polyline points="22,12 18,8 13,13 9,9 2,16" />
    <polyline points="22,12 22,8 18,8" />
  </svg>

let barChart = (~color: string) =>
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="12" width="4" height="9" rx="1" />
    <rect x="10" y="7" width="4" height="14" rx="1" />
    <rect x="17" y="3" width="4" height="18" rx="1" />
  </svg>

let columnChart = (~color: string) =>
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="3" width="18" height="4" rx="1" />
    <rect x="3" y="10" width="12" height="4" rx="1" />
    <rect x="3" y="17" width="7" height="4" rx="1" />
  </svg>

let pieChart = (~color: string) =>
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M21.21 15.89A10 10 0 1 1 8 2.83" />
    <path d="M22 12A10 10 0 0 0 12 2v10z" />
  </svg>

let stackedChart = (~color: string) =>
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="4" y="14" width="5" height="7" rx="1" />
    <rect x="4" y="8" width="5" height="6" rx="1" />
    <rect x="13" y="10" width="5" height="11" rx="1" />
    <rect x="13" y="4" width="5" height="6" rx="1" />
  </svg>

let funnelChart = (~color: string) =>
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M3 4h18l-6 7v6l-6 3V11L3 4z" />
  </svg>

let getChartIcon = (chartType: CustomDashboardTypes.chartType, ~isActive: bool) => {
  let color = isActive ? "#2563eb" : "#9ca3af"
  switch chartType {
  | LineChart => lineChart(~color)
  | BarChart => barChart(~color)
  | ColumnChart => columnChart(~color)
  | PieChart => pieChart(~color)
  | StackedBarChart => stackedChart(~color)
  | FunnelChart | SankeyChart => funnelChart(~color)
  }
}

// Domain icons — uniform stroke style
let payments = (~color: string) =>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="1" y="4" width="22" height="16" rx="2" />
    <line x1="1" y1="10" x2="23" y2="10" />
  </svg>

let smartRetries = (~color: string) =>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <polyline points="1,4 1,10 7,10" />
    <polyline points="23,20 23,14 17,14" />
    <path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10" />
    <path d="M3.51 15A9 9 0 0 0 18.36 18.36L23 14" />
  </svg>

let refunds = (~color: string) =>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <polyline points="1,4 1,10 7,10" />
    <path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10" />
  </svg>

let disputes = (~color: string) =>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
    <line x1="12" y1="9" x2="12" y2="13" />
    <line x1="12" y1="17" x2="12.01" y2="17" />
  </svg>

let authentication = (~color: string) =>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
  </svg>

let routing = (~color: string) =>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="5" r="3" />
    <circle cx="5" cy="19" r="3" />
    <circle cx="19" cy="19" r="3" />
    <line x1="12" y1="8" x2="5" y2="16" />
    <line x1="12" y1="8" x2="19" y2="16" />
  </svg>

let getDomainIcon = (domain: CustomDashboardTypes.analyticsDomain, ~isActive: bool) => {
  let color = isActive ? "#2563eb" : "#9ca3af"
  switch domain {
  | Payments => payments(~color)
  | SmartRetries => smartRetries(~color)
  | Refunds => refunds(~color)
  | Disputes => disputes(~color)
  | AuthEvents => authentication(~color)
  | Routing => routing(~color)
  }
}
