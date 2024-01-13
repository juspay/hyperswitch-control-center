@scope("JSON") @val
external parseIntoMyData: string => Js.Json.t = "parse"

type jsonData = {data: Js.Json.t}
external convertToCustomEvent: Webapi.Dom.Event.t => jsonData = "%identity"

let getEventDict = (ev: Dom.event) => {
  let objData = ev->convertToCustomEvent
  try {
    objData.data
    ->Js.Json.decodeString
    ->Belt.Option.map(Js.Json.parseExn)
    ->Belt.Option.flatMap(parsedMsg => {
      parsedMsg->Js.Json.decodeObject
    })
  } catch {
  | _ => None
  }
}

type cookieData = {changed: Js.Array2.t<Js.Json.t>}
external convertToCookieCustomEvent: Webapi.Dom.Event.t => cookieData = "%identity"
