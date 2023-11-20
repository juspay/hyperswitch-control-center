type dashboardMode = [
  | #batchMode
  | #liveMode
]

type dashboardModeContextType = {
  dashboardMode: dashboardMode,
  setDashboardMode: dashboardMode => unit,
}

let dashboardModeContextDefaultValue = {
  dashboardMode: #batchMode,
  setDashboardMode: _ => (),
}

let dashboardModeContext = React.createContext(dashboardModeContextDefaultValue)

module DashboardModeProvider = {
  let make = React.Context.provider(dashboardModeContext)
}

@react.component
let make = (~children) => {
  let (dashboardMode, setDashboardMode) = React.useState(_ => #batchMode)
  let contextValue = {
    dashboardMode,
    setDashboardMode: dashboardMode => setDashboardMode(_ => dashboardMode),
  }

  <DashboardModeProvider value={contextValue}> children </DashboardModeProvider>
}
