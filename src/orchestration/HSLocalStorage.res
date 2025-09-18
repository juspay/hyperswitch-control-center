let getInfoFromLocalStorage = (~lStorageKey) => {
  let stringifiedJson = LocalStorage.getItem(lStorageKey)->LogicUtils.getValFromNullableValue("")

  stringifiedJson->LogicUtils.safeParse->LogicUtils.getDictFromJsonObject
}

let getBooleanFromLocalStorage = (~key) => {
  let stringifiedJson = LocalStorage.getItem(key)->LogicUtils.getValFromNullableValue("")

  stringifiedJson->LogicUtils.safeParse->LogicUtils.getBoolFromJson(false)
}

let getFromUserDetails = key => {
  getInfoFromLocalStorage(~lStorageKey="user")->LogicUtils.getString(key, "")
}

let getIsPlaygroundFromLocalStorage = () => {
  getBooleanFromLocalStorage(~key="isPlayground")
}

let setIsPlaygroundInLocalStorage = (val: bool) => {
  LocalStorage.setItem("isPlayground", val->JSON.Encode.bool->JSON.stringify)
}

let removeItemFromLocalStorage = (~key) => {
  LocalStorage.removeItem(key)
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

let setCustomTableHeadersInLocalStorage = val => {
  let val = val->LogicUtils.getNonEmptyString
  if val->Option.isSome {
    LocalStorage.setItem("tableColumnsOrder", val->Option.getOr(""))
  }
}

let getCustomTableColumnsfromLocalStorage = () => {
  let customTableColumns = LocalStorage.getItem("tableColumnsOrder")->Nullable.toOption
  customTableColumns
}
