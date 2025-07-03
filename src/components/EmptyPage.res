@react.component
let make = (~path) => {
  React.useEffect(() => {
    Js.log2("LOg", path)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=path))
    None
  }, [])
  React.null
}
