open MonitoringTypes

@react.component
let make = (~destination) => {
  let bootstrap = MonitoringHooks.useGrafanaSession()
  let checkDocument = MonitoringHooks.useGrafanaDocument()
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let theme = switch ThemeProvider.useTheme() {
  | Light => "light"
  | Dark => "dark"
  }
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (retryCount, setRetryCount) = React.useState(_ => 0)
  let (frameLoaded, setFrameLoaded) = React.useState(_ => false)

  React.useEffect(() => {
    let controller = Fetch.AbortController.make()
    let signal = controller->Fetch.AbortController.signal
    setScreenState(_ => Loading)
    setFrameLoaded(_ => false)
    let timer = setTimeout(() => {
      setScreenState(_ => Failed("Monitoring took too long to respond. Please try again.", true))
      controller->Fetch.AbortController.abort
    }, 30000)
    let loadSession = async () => {
      try {
        let result = await bootstrap(~destination, ~signal)
        if !(signal->AbortControllerHook.isAborted) {
          clearTimeout(timer)
          setScreenState(_ => result)
        }
      } catch {
      | _ =>
        if !(signal->AbortControllerHook.isAborted) {
          clearTimeout(timer)
          setScreenState(_ => Failed("Unable to connect to Monitoring. Please try again.", true))
        }
      }
    }
    loadSession()->ignore
    Some(
      () => {
        clearTimeout(timer)
        controller->Fetch.AbortController.abort
      },
    )
  }, (retryCount, authStatus))

  let embedUrl = switch screenState {
  | Ready(url) => MonitoringUtils.getEmbedUrl(~embedUrl=url, ~theme)
  | _ => None
  }

  React.useEffect(() => {
    setFrameLoaded(_ => false)
    None
  }, [embedUrl])

  React.useEffect(() => {
    switch embedUrl {
    | Some(_) if !frameLoaded =>
      let timer = setTimeout(() => {
        setScreenState(
          _ => Failed("The monitoring view took too long to load. Please try again.", true),
        )
      }, 30000)
      Some(() => clearTimeout(timer))
    | _ => None
    }
  }, (embedUrl, frameLoaded))

  React.useEffect(() => {
    switch embedUrl {
    | Some(url) =>
      let controller = Fetch.AbortController.make()
      let signal = controller->Fetch.AbortController.signal
      let checking = ref(false)
      let timeout = ref(None)
      let checkSession = async () => {
        if !checking.contents && !(signal->AbortControllerHook.isAborted) {
          checking.contents = true
          timeout.contents = Some(setTimeout(() => {
              setScreenState(
                _ => Failed("Monitoring took too long to respond. Please try again.", true),
              )
              controller->Fetch.AbortController.abort
            }, 30000))
          try {
            let result = await checkDocument(~embedUrl=url, ~signal)
            if !(signal->AbortControllerHook.isAborted) {
              switch result {
              | Ready(_) => ()
              | _ => setScreenState(_ => result)
              }
            }
          } catch {
          | _ =>
            if !(signal->AbortControllerHook.isAborted) {
              setScreenState(_ => Failed(
                "Monitoring is temporarily unavailable. Please try again.",
                true,
              ))
            }
          }
          timeout.contents->Option.forEach(clearTimeout)
          checking.contents = false
        }
      }
      // Recheck an idle view too: no Grafana refresh is required to notice session expiry.
      let interval = setInterval(() => checkSession()->ignore, 60000)
      Some(
        () => {
          clearInterval(interval)
          timeout.contents->Option.forEach(clearTimeout)
          controller->Fetch.AbortController.abort
        },
      )
    | None => None
    }
  }, [embedUrl])

  let renderError = (message, canRetry) =>
    <div className="flex flex-col items-center justify-center gap-4 min-h-96" role="alert">
      <p className="text-sm text-nd_gray-600 dark:text-white"> {message->React.string} </p>
      <RenderIf condition=canRetry>
        <Button text="Retry" onClick={_ => setRetryCount(count => count + 1)} />
      </RenderIf>
    </div>

  <div className="w-full min-w-0" id="monitoring-screen">
    <PageUtils.PageHeading
      title={destination->MonitoringUtils.getTitle}
      customHeadingStyle="mb-4"
      customTitleStyle="dark:text-white"
    />
    {switch screenState {
    | Loading => <PageLoaderWrapper.ScreenLoader />
    | Failed(message, canRetry) => renderError(message, canRetry)
    | Ready(_) =>
      switch embedUrl {
      | None => renderError("Monitoring returned a URL outside the approved gateway.", true)
      | Some(src) =>
        <div className="relative w-full">
          <RenderIf condition={!frameLoaded}>
            <div className="absolute inset-0 bg-white dark:bg-jp-gray-lightgray_background">
              <PageLoaderWrapper.ScreenLoader />
            </div>
          </RenderIf>
          <iframe
            key=src
            title={destination->MonitoringUtils.getTitle}
            src
            className="w-full border-0 rounded-lg"
            style={ReactDOM.Style.make(~height="calc(100vh - 180px)", ~minHeight="480px", ())}
            onLoad={_ => setFrameLoaded(_ => true)}
            onError={_ => setScreenState(_ => Failed("Unable to load the monitoring view.", true))}
          />
        </div>
      }
    }}
  </div>
}
