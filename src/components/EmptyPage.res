@react.component
let make = (~path) => {
  React.useEffect(() => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=path))
    None
  }, [])
  React.null
}
