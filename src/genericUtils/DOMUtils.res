type document = {mutable title: string}
type window
@val external document: document = "document"
@send external getElementById: (document, string) => Dom.element = "getElementById"
@send external createElement: (document, string) => Dom.element = "createElement"
@val external window: window = "window"
@send external click: (Dom.element, unit) => unit = "click"
@send external reset: (Dom.element, unit) => unit = "reset"
@val @scope("window") external parent: window = "parent"
type event
@new
external event: string => event = "Event"
@send external dispatchEvent: ('a, event) => unit = "dispatchEvent"
@send external postMessage: (window, Js.Json.t, string) => unit = "postMessage"

@val @scope(("window", "location")) external windowOrigin: string = "origin"
external toString: option<Js.Json.t> => string = "%identity"
external convertToStrDict: 't => Js.Json.t = "%identity"
external evToString: ReactEvent.Form.t => string = "%identity"
external objToJson: {..} => Js.Json.t = "%identity"

external toJson: exn => Js.Json.t = "%identity"
external toRespJson: Fetch.Response.t => Js.Json.t = "%identity"
@get external keyCode: 'a => int = "keyCode"
external formEventToStr: ReactEvent.Form.t => string = "%identity"

external formEventToBoolean: ReactEvent.Form.t => bool = "%identity"
@send external querySelectorAll: (document, string) => array<Dom.element> = "querySelectorAll"
