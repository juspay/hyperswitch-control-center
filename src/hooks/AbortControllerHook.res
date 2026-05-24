@get external isAborted: Fetch.signal => bool = "aborted"

let useAbortController = () => {
  let abortControllerRef = React.useRef(None)

  React.useEffect(() => {
    Some(() => abortControllerRef.current->Option.forEach(Fetch.AbortController.abort))
  }, [])

  () => {
    abortControllerRef.current->Option.forEach(controller =>
      controller->Fetch.AbortController.abort
    )
    let newController = Fetch.AbortController.make()
    abortControllerRef.current = Some(newController)
    newController->Fetch.AbortController.signal
  }
}
