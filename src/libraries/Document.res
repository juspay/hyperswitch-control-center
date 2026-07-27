type domElement

type document = {querySelectorAll: string => array<domElement>}
@val external document: document = "document"

@val @scope("document")
external querySelector: string => Nullable.t<domElement> = "querySelector"
@val @scope("document")
external activeElement: Dom.element = "activeElement"

@send external click: (domElement, unit) => unit = "click"
@get external offsetWidth: Dom.element => int = "offsetWidth"

module Fullscreen = {
  @get @return(nullable)
  external getElement: Dom.document => option<Dom.element> = "fullscreenElement"

  let request: Dom.element => promise<unit> = %raw(`
    element => typeof element.requestFullscreen === "function"
      ? element.requestFullscreen()
      : Promise.resolve()
  `)

  let exit: Dom.document => promise<unit> = %raw(`
    document => typeof document.exitFullscreen === "function"
      ? document.exitFullscreen()
      : Promise.resolve()
  `)
}
