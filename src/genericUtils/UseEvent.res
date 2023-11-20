let useEvent0 = callback => {
  let callbackRef = React.useRef(callback)
  React.useEffect1(() => {
    callbackRef.current = callback

    None
  }, [callback])

  React.useCallback0(() => {
    callbackRef.current()
  })
}
let useEvent1 = callback => {
  let callbackRef = React.useRef(callback)
  React.useEffect1(() => {
    callbackRef.current = callback

    None
  }, [callback])

  React.useCallback0(a => {
    callbackRef.current(a)
  })
}
