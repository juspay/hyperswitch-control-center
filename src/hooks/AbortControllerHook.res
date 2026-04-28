let useAbortController = () => {
  let abortControllerRef = React.useRef(None)

  () => {
    abortControllerRef.current->Option.forEach(controller =>
      controller->Fetch.AbortController.abort
    )
    let newController = Fetch.AbortController.make()
    abortControllerRef.current = Some(newController)
    newController->Fetch.AbortController.signal
  }
}
