external toBool: 'a => bool = "%identity"

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
  let elem = document.documentElement
  if elem.requestFullscreen->toBool {
    elem.requestFullscreen(.)
  } else if elem.mozRequestFullScreen->toBool {
    elem.mozRequestFullScreen(.) // Firefox
  } else if elem.webkitRequestFullscreen->toBool {
    elem.webkitRequestFullscreen(.) // Chrome, Safari, and Opera
  } else if elem.msRequestFullscreen->toBool {
    elem.msRequestFullscreen(.) // Internet Explorer/Edge
  }
}

let exitFullscreen = () => {
  if document.exitFullscreen->toBool {
    document.exitFullscreen(.)
  } else if document.mozCancelFullScreen->toBool {
    document.mozCancelFullScreen(.) // Firefox
  } else if document.msExitFullscreen->toBool {
    document.msExitFullscreen(.) // Internet Explorer/Edge
  } else if document.webkitExitFullscreen->toBool {
    document.webkitExitFullscreen(.) // Chrome, Safari, and Opera
  }
}
