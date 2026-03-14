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

// HTMLInputElement bindings
type htmlInputElement
@set external setInputValue: (htmlInputElement, string) => unit = "value"
@get external getInputValue: htmlInputElement => string = "value"
external toInputElement: Dom.element => htmlInputElement = "%identity"

type contentRect = {height: float, width: float}
type resizeObserverEntry = {contentRect: contentRect}
type resizeObserver

@new @scope("window")
external createResizeObserver: (array<resizeObserverEntry> => unit) => resizeObserver =
  "ResizeObserver"
@send external observeElement: (resizeObserver, Dom.element) => unit = "observe"
@send external disconnectObserver: resizeObserver => unit = "disconnect"
@get external scrollHeight: Dom.element => int = "scrollHeight"
@get external offsetHeight: Dom.element => int = "offsetHeight"
@get external clientHeight: Dom.element => int = "clientHeight"
@get external scrollWidth: Dom.element => int = "scrollWidth"
@get external offsetWidth: Dom.element => int = "offsetWidth"
@get external clientWidth: Dom.element => int = "clientWidth"
