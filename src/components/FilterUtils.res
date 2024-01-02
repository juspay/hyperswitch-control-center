let generateDefaultUrl = dict => {
  dict
  ->Dict.toArray
  ->Belt.Array.keepMap(entry => {
    let (key, val) = entry

    let strValue = RemoteFiltersUtils.getStrFromJson(key, val)
    if strValue !== "" {
      Some(`${key}=${strValue}`)
    } else {
      None
    }
  })
  ->Array.joinWith("&")
}

let updateURLWithDefaultFilter = (~path, ~filterParam, ~filterString) => {
  if path->String.length > 0 && filterParam->String.length == 0 {
    let finalUrl = `${path}?${filterString}`
    RescriptReactRouter.replace(finalUrl)
  }
}
