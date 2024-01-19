@react.component
let make = (~isEnabled, ~children) => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)

  let updateRoute = () => {
    setDashboardPageState(_ => #HOME)
    RescriptReactRouter.replace("/home")
    React.null
  }
  isEnabled ? children : updateRoute()
}
