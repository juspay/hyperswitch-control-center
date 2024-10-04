open UserTimeZoneTypes
let defaultSetter = _ => ()

let userTimeContext = React.createContext((IST, defaultSetter))

module TimeZone = {
  let make = React.Context.provider(userTimeContext)
}

@react.component
let make = (~children) => {
  let (zone, setZoneBase) = React.useState(_ => UserTimeZoneTypes.IST)
  let setZone = React.useCallback(value => {
    setZoneBase(_ => value)
  }, [setZoneBase])

  <TimeZone value=(zone, setZone)> children </TimeZone>
}
