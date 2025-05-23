type document = {mutable title: string}
type window = {mutable _env_: HyperSwitchConfigTypes.urlConfig}
@val external document: document = "document"
@send external getElementById: (document, string) => Dom.element = "getElementById"
@send external createElement: (document, string) => Dom.element = "createElement"
@send external createTextNode: (document, string) => Dom.element = "createTextNode"
@val external window: window = "window"
@send external click: (Dom.element, unit) => unit = "click"
@send external reset: (Dom.element, unit) => unit = "reset"

type event
@new
external event: string => event = "Event"
@send external dispatchEvent: ('a, event) => unit = "dispatchEvent"
@send external postMessage: (window, JSON.t, string) => unit = "postMessage"
@get external keyCode: 'a => int = "keyCode"
@send external querySelectorAll: (document, string) => array<Dom.element> = "querySelectorAll"
@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@send external remove: (Dom.element, unit) => unit = "remove"
@scope(("document", "body"))
external appendChild: Dom.element => unit = "appendChild"

@scope(("document", "head"))
external appendHead: Dom.element => unit = "appendChild"
external domProps: {..} => JsxDOM.domProps = "%identity"
@set external elementOnload: (Dom.element, unit => unit) => unit = "onload"
