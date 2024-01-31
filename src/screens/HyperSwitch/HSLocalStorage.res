let getInfoFromLocalStorage = (~lStorageKey) => {
  let stringifiedJson = LocalStorage.getItem(lStorageKey)->Nullable.toOption->Option.getOr("")

  stringifiedJson->LogicUtils.safeParse->LogicUtils.getDictFromJsonObject
}

let getBooleanFromLocalStorage = (~key) => {
  let stringifiedJson = LocalStorage.getItem(key)->Nullable.toOption->Option.getOr("")

  stringifiedJson->LogicUtils.safeParse->LogicUtils.getBoolFromJson(false)
}

let getFromMerchantDetails = key => {
  getInfoFromLocalStorage(~lStorageKey="merchant")->LogicUtils.getString(key, "")
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
