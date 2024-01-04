open LogicUtils

type moduleVisePref = {
  searchParams?: string,
  moduleConfig?: Js.Dict.t<Js.Json.t>, // we store array of string here
}
type userPref = {
  lastVisitedTab?: string,
  moduleVisePref?: Js.Dict.t<moduleVisePref>,
}
external userPrefToJson: userPref => Js.Json.t = "%identity"

// DO NOT CHANGE THE KEYS
let userPreferenceKeyInLocalStorage = "userPreferences"
let lastVisitedTabKey = "lastVisitedTab"
let moduleWisePrefKey = "moduleVisePref"
let moduleConfig = "moduleConfig"
let urlKey = "searchParams"

let convertToModuleVisePref = json => {
  let dict = json->LogicUtils.getDictFromJsonObject

  dict
  ->Dict.keysToArray
  ->Array.map(key => {
    let jsonForTheDict = dict->LogicUtils.getDictfromDict(key)
    let value = {
      searchParams: jsonForTheDict->LogicUtils.getString(urlKey, ""),
      moduleConfig: jsonForTheDict
      ->LogicUtils.getJsonObjectFromDict(moduleConfig)
      ->LogicUtils.getDictFromJsonObject,
    }
    (key, value)
  })
  ->Dict.fromArray
}

let converToUserPref = dict => {
  dict
  ->Dict.keysToArray
  ->Array.map(key => {
    let jsonForTheDict = dict->LogicUtils.getDictfromDict(key)
    let value = {
      lastVisitedTab: getString(jsonForTheDict, lastVisitedTabKey, ""),
      moduleVisePref: getJsonObjectFromDict(
        jsonForTheDict,
        moduleWisePrefKey,
      )->convertToModuleVisePref,
    }
    (key, value)
  })
  ->Dict.fromArray
}

// this will be changed to api call on every change to url this save will happen
let saveUserPref = (userPref: Js.Dict.t<userPref>) => {
  LocalStorage.setItem(
    userPreferenceKeyInLocalStorage,
    userPref
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      (key, value->userPrefToJson)
    })
    ->Dict.fromArray
    ->Js.Json.object_
    ->Js.Json.stringify,
  )
}

// this will be changed to api call for updatedUserPref the call will happen only once in initialLoad and we will store it in context
let getUserPref = () => {
  switch LocalStorage.getItem(userPreferenceKeyInLocalStorage)->Js.Nullable.toOption {
  | Some(str) =>
    str
    ->LogicUtils.safeParse
    ->Js.Json.decodeObject
    ->Belt.Option.getWithDefault(Dict.make())
    ->converToUserPref

  | None => Dict.make()
  }
}

let getSearchParams = (moduleWisePref: Js.Dict.t<moduleVisePref>, ~key: string) => {
  switch moduleWisePref->Dict.get(key)->Belt.Option.getWithDefault({}) {
  | {searchParams} => searchParams
  | _ => ""
  }
}
