let generateDefaultUrl = dict => {
  dict
  ->Js.Dict.entries
  ->Belt.Array.keepMap(entry => {
    let (key, val) = entry

    let strValue = RemoteFiltersUtils.getStrFromJson(key, val)
    if strValue !== "" {
      Some(`${key}=${strValue}`)
    } else {
      None
    }
  })
  ->Js.Array2.joinWith("&")
}

let updateURLWithDefaultFilter = (~path, ~filterParam, ~filterString) => {
  if path->Js.String2.length > 0 && filterParam->Js.String2.length == 0 {
    let finalUrl = `${path}?${filterString}`
    RescriptReactRouter.replace(finalUrl)
  }
}
