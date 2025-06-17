@react.component
let make = () => {
  React.useEffect(() => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
    None
  }, [])
  React.null
}
