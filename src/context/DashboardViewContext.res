type dashboardView = [
  | #ordersView
  | #txnView
]

type dashboardViewContextType = {
  dashboardView: dashboardView,
  setDashboardView: dashboardView => unit,
}

let dashboardViewContextDefaultValue = {
  dashboardView: #ordersView,
  setDashboardView: _ => (),
}

let dashboardViewContext = React.createContext(dashboardViewContextDefaultValue)

module DashboardViewProvider = {
  let make = React.Context.provider(dashboardViewContext)
}

@react.component
let make = (~children) => {
  let (dashboardView, setDashboardView) = React.useState(_ => #ordersView)
  let contextValue = {
    dashboardView,
    setDashboardView: dashboardView => setDashboardView(_ => dashboardView),
  }

  <DashboardViewProvider value={contextValue}> children </DashboardViewProvider>
}
