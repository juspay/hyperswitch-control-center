@react.component
let make = () => {
  let (subView, setSubView) = React.useState(_ => CustomDashboardTypes.DashboardListView)

  switch subView {
  | DashboardListView =>
    <DashboardList
      onOpenDashboard={dashboard => setSubView(_ => DashboardCanvasView(dashboard))}
    />
  | DashboardCanvasView(dashboard) =>
    <DashboardCanvas dashboard onBack={() => setSubView(_ => DashboardListView)} />
  }
}
