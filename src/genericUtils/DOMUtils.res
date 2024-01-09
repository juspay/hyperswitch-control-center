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
@get external keyCode: 'a => int = "keyCode"
@send external querySelectorAll: (document, string) => array<Dom.element> = "querySelectorAll"
@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@send external remove: (Dom.element, unit) => unit = "remove"
@scope(("document", "body"))
external appendChild: Dom.element => unit = "appendChild"
