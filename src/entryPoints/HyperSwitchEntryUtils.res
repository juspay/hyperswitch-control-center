open SessionStorage
open LogicUtils
let setSessionData = (~key, ~searchParams) => {
  let result = searchParams->getDictFromUrlSearchParams->Dict.get(key)
  switch result {
  | Some(data) => sessionStorage.setItem(key, data)
  | None => ()
  }
}

let getSessionData = (~key, ~defaultValue="") => {
  let result = sessionStorage.getItem(key)->Nullable.toOption->Option.getOr("")->getNonEmptyString
  switch result {
  | Some(data) => data
  | None => defaultValue
  }
}

let getThemeIdfromStore = () => {
  let themeId = LocalStorage.getItem("theme_id")->Nullable.toOption
  themeId
}
let getThemeConfigVersionfromStore = () => {
  let themeConfigVersion = LocalStorage.getItem("themeConfigVersion")->Nullable.toOption
  themeConfigVersion
}

let setThemeConfigVersiontoStore = themeConfigVersion => {
  let version = themeConfigVersion->getNonEmptyString
  if version->Option.isSome {
    LocalStorage.setItem("themeConfigVersion", version->Option.getOr(""))
  } else {
    ()
  }
}

let setThemeIdtoStore = themeId => {
  let themeID = themeId->getNonEmptyString
  if themeID->Option.isSome {
    LocalStorage.setItem("theme_id", themeID->Option.getOr(""))
  } else {
    LocalStorage.setItem("theme_id", "") //to change back to default if no theme present on switch
  }
}

let getSuperpositionDisplayConfig = (
  configKey: string,
): HyperSwitchConfigTypes.superpositionDisplayConfig => {
  switch configKey->String.lastIndexOf(".") {
  | -1 => {folder: None, name: configKey}
  | index => {
      folder: configKey->String.slice(~start=0, ~end=index)->getNonEmptyString,
      name: configKey->String.sliceToEnd(~start=index + 1),
    }
  }
}

let getSuperpositionConfigMapper: Dict.t<
  JSON.t,
> => HyperSwitchConfigTypes.superpositionConfig = dict => {
  {
    organization_id: dict->getString("organization_id", ""),
    workspace: dict->getString("workspace", ""),
    display_configs: dict
    ->getString("display_configs", "")
    ->String.split(",")
    ->Array.filterMap(configKey => configKey->String.trim->getNonEmptyString)
    ->Array.map(getSuperpositionDisplayConfig),
  }
}
