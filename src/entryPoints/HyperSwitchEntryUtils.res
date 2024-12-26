open SessionStorage
open LogicUtils
let setSessionData = (~key, ~searchParams) => {
  let result = searchParams->getDictFromUrlSearchParams->Dict.get(key)
  switch result {
  | Some(data) => sessionStorage.setItem(key, data)
  | None => ()
  }
}

let setSessionDataFromHostname = (~key, ~domain) =>
  if domain != "default" {
    sessionStorage.setItem(key, domain)
  }

let getSessionData = (~key, ~defaultValue="") => {
  let result = sessionStorage.getItem(key)->Nullable.toOption->Option.getOr("")->getNonEmptyString
  switch result {
  | Some(data) => data
  | None => defaultValue
  }
}
