let getInfoFromLocalStorage = (~lStorageKey) => {
  let stringifiedJson =
    LocalStorage.getItem(lStorageKey)->Js.Nullable.toOption->Belt.Option.getWithDefault("")

  stringifiedJson->LogicUtils.safeParse->LogicUtils.getDictFromJsonObject
}

let getBooleanFromLocalStorage = (~key) => {
  let stringifiedJson =
    LocalStorage.getItem(key)->Js.Nullable.toOption->Belt.Option.getWithDefault("")

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
  LocalStorage.setItem("isPlayground", val->Js.Json.boolean->Js.Json.stringify)
}
