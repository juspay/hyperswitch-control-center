open UserTimeZoneTypes
let defaultSetter = (_: timeZoneType) => ()

let userTimeContext = React.createContext((IST, defaultSetter))

module TimeZone = {
  let make = React.Context.provider(userTimeContext)
}

@react.component
let make = (~children) => {
  let (zone, setZoneBase) = React.useState(_ => UserTimeZoneTypes.IST)
  let setZone = React.useCallback1(value => {
    setZoneBase(_ => value)
  }, [setZoneBase])

  <TimeZone value=(zone, setZone)> children </TimeZone>
}
