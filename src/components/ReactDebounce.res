let useDebounced = (~wait=?, fn) => {
  let ref = React.useRef(Debounce.make(~wait?, fn))
  ref.current
}

let useControlled = (~wait=?, fn) => {
  let ref = React.useRef(Debounce.makeControlled(~wait?, fn))
  ref.current
}
