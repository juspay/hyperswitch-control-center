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

let setThemeIdtoStore = themeId => {
  let themeID = themeId->LogicUtils.getNonEmptyString
  if themeID->Option.isSome {
    LocalStorage.setItem("theme_id", themeID->Option.getOr(""))
    sessionStorage.removeItem("domain")
  } else {
    LocalStorage.setItem("theme_id", "")
  }
}

let getDomainfromSession = () => {
  let domain = getSessionData(~key="domain")->LogicUtils.getNonEmptyString
  domain
}
