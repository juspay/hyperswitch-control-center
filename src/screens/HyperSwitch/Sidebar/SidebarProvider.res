open ProviderTypes

let setIsSidebarDetails = (key, value) => {
  let localStorageData = HSLocalStorage.getInfoFromLocalStorage(~lStorageKey="sidebar")
  localStorageData->Dict.set(key, value)
  "sidebar"->LocalStorage.setItem(
    localStorageData->Js.Json.stringifyAny->Belt.Option.getWithDefault(""),
  )
}

let getFromSidebarDetails = key => {
  HSLocalStorage.getInfoFromLocalStorage(~lStorageKey="sidebar")->LogicUtils.getBool(key, false)
}

let defaultValue = {
  isSidebarExpanded: false,
  setIsSidebarExpanded: _ => (),
  getFromSidebarDetails,
  setIsSidebarDetails,
}

let defaultContext = React.createContext(defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let (isSidebarExpanded, setIsSidebarExpanded) = React.useState(_ => false)

  <Provider
    value={
      isSidebarExpanded,
      setIsSidebarExpanded,
      getFromSidebarDetails,
      setIsSidebarDetails,
    }>
    children
  </Provider>
}
