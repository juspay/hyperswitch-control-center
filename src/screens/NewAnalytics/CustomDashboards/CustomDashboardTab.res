// Global styles for transparent Highcharts backgrounds (injected once)
let chartStyles = `
  .chart-bg-gradient .highcharts-background { fill: transparent !important; }
  .chart-bg-gradient .highcharts-plot-background { fill: transparent !important; }
`

@react.component
let make = () => {
  let (subView, setSubView) = React.useState(_ => CustomDashboardTypes.DashboardListView)

  <>
    <style> {React.string(chartStyles)} </style>
    {switch subView {
    | DashboardListView =>
      <DashboardList
        onOpenDashboard={dashboard => setSubView(_ => DashboardCanvasView(dashboard))}
      />
    | DashboardCanvasView(dashboard) =>
      <DashboardCanvas dashboard onBack={() => setSubView(_ => DashboardListView)} />
    }}
  </>
}
