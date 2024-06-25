open SessionStorage
let setSessionData = (~key, ~searchParams) => {
  open LogicUtils
  let result = searchParams->getDictFromUrlSearchParams->Dict.get(key)
  switch result {
  | Some(data) => sessionStorage.setItem(. key, data)
  | None => ()
  }
}

let getSessionData = (~key) => {
  sessionStorage.getItem(. key)->Nullable.toOption->Option.getOr("")
}
