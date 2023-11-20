type domElement

type document = {querySelectorAll: (. string) => array<domElement>}
@val external document: document = "document"

@val @scope("document")
external querySelector: string => Js.Nullable.t<domElement> = "querySelector"
@val @scope("document")
external activeElement: Dom.element = "activeElement"

@send external click: (domElement, unit) => unit = "click"
@get external offsetWidth: Dom.element => int = "offsetWidth"
