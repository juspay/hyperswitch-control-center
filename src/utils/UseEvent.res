let useEvent0 = callback => {
  let callbackRef = React.useRef(callback)
  React.useEffect(() => {
    callbackRef.current = callback

    None
  }, [callback])

  React.useCallback(() => {
    callbackRef.current()
  }, [])
}
