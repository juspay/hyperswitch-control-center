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
  } else {
    LocalStorage.setItem("theme_id", "") //to change back to default if no theme present on switch
  }
}

let setDomaintoStore = domain => {
  let domain = domain->LogicUtils.getNonEmptyString
  if domain->Option.isSome {
    LocalStorage.setItem("domain", domain->Option.getOr(""))
  }
}

let getDomainfromStore = () => {
  let domain = LocalStorage.getItem("domain")->Nullable.toOption
  domain
}
