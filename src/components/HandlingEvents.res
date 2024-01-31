@scope("JSON") @val
external parseIntoMyData: string => JSON.t = "parse"

type jsonData = {data: JSON.t}
external convertToCustomEvent: Webapi.Dom.Event.t => jsonData = "%identity"

let getEventDict = (ev: Dom.event) => {
  let objData = ev->convertToCustomEvent
  try {
    objData.data
    ->JSON.Decode.string
    ->Option.map(JSON.parseExn)
    ->Option.flatMap(parsedMsg => {
      parsedMsg->JSON.Decode.object
    })
  } catch {
  | _ => None
  }
}

type cookieData = {changed: array<JSON.t>}
external convertToCookieCustomEvent: Webapi.Dom.Event.t => cookieData = "%identity"
