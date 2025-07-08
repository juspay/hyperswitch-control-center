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
let setCustomTableHeaders = val => {
  let val = val->LogicUtils.getNonEmptyString
  if val->Option.isSome {
    LocalStorage.setItem("tableColumnsOrder", val->Option.getOr(""))
  }
}
let getCustomTableColumnsfromStore = () => {
  let customTableColumns = LocalStorage.getItem("tableColumnsOrder")->Nullable.toOption
  customTableColumns
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
let getEmailfromStore = () => {
  let email = LocalStorage.getItem("email")->Nullable.toOption
  email
}
let setEmailToStore = email => {
  let email = email->LogicUtils.getNonEmptyString
  if email->Option.isSome {
    LocalStorage.setItem("email", email->Option.getOr(""))
  }
}

let handleSavedColumnsInStore = email => {
  let optionalEmail = Some(email)
  let savedEmail = getEmailfromStore()->Option.getOr("")
  let getCustomTableColumnsfromStore = getCustomTableColumnsfromStore()
  if {
    (!(savedEmail == email) || optionalEmail->Option.isNone) &&
      getCustomTableColumnsfromStore->Option.isSome
  } {
    LocalStorage.removeItem("tableColumnsOrder")
  } else {
    ()
  }
}
