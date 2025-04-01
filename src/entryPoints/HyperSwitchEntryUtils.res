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

let updateSessionData = (~key, ~value) => {
  sessionStorage.setItem(key, value)
  value
}

let setMultipleSessionData = (~keys: array<string>, ~searchParams) => {
  let params = searchParams->getDictFromUrlSearchParams

  keys->Array.forEach(key => {
    let result = params->Dict.get(key)
    switch result {
    | Some(data) => sessionStorage.setItem(key, data)
    | None => ()
    }
  })
}

let setSessionAndLocalData = (~key, ~searchParams) => {
  let result = searchParams->getDictFromUrlSearchParams->Dict.get(key)
  switch result {
  | Some(data) => {
      sessionStorage.setItem(key, data)
      LocalStorage.setItem(key, data)
    }
  | None => ()
  }
}

let updateSessionAndLocalData = (~key, ~value) => {
  sessionStorage.setItem(key, value)
  LocalStorage.updateItem(key, value)
}
