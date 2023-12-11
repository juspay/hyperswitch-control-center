type elem = {
  requestFullscreen: (. unit) => unit,
  mozRequestFullScreen: (. unit) => unit,
  webkitRequestFullscreen: (. unit) => unit,
  msRequestFullscreen: (. unit) => unit,
}

type document = {
  documentElement: elem,
  fullscreen: bool,
  exitFullscreen: (. unit) => unit,
  mozCancelFullScreen: (. unit) => unit,
  webkitExitFullscreen: (. unit) => unit,
  msExitFullscreen: (. unit) => unit,
}

@val external document: document = "document"

let enableFullscreen = () => {
  open Identity
  let elem = document.documentElement
  if elem.requestFullscreen->genericTypeToBool {
    elem.requestFullscreen(.)
  } else if elem.mozRequestFullScreen->genericTypeToBool {
    elem.mozRequestFullScreen(.) // Firefox
  } else if elem.webkitRequestFullscreen->genericTypeToBool {
    elem.webkitRequestFullscreen(.) // Chrome, Safari, and Opera
  } else if elem.msRequestFullscreen->genericTypeToBool {
    elem.msRequestFullscreen(.) // Internet Explorer/Edge
  }
}

let exitFullscreen = () => {
  open Identity
  if document.exitFullscreen->genericTypeToBool {
    document.exitFullscreen(.)
  } else if document.mozCancelFullScreen->genericTypeToBool {
    document.mozCancelFullScreen(.) // Firefox
  } else if document.msExitFullscreen->genericTypeToBool {
    document.msExitFullscreen(.) // Internet Explorer/Edge
  } else if document.webkitExitFullscreen->genericTypeToBool {
    document.webkitExitFullscreen(.) // Chrome, Safari, and Opera
  }
}
