open MonitoringTypes

@react.component
let make = (~destination) => {
  let bootstrap = MonitoringHooks.useGrafanaSession()
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let theme = switch ThemeProvider.useTheme() {
  | Light => "light"
  | Dark => "dark"
  }
  let (screenState, setScreenState) = React.useState(_ => Loading)

  React.useEffect(() => {
    let controller = Fetch.AbortController.make()
    let signal = controller->Fetch.AbortController.signal
    setScreenState(_ => Loading)
    let loadSession = async () => {
      try {
        let result = await bootstrap(~destination, ~signal)
        if !(signal->AbortControllerHook.isAborted) {
          setScreenState(_ => result)
        }
      } catch {
      | _ =>
        if !(signal->AbortControllerHook.isAborted) {
          setScreenState(_ => Failed("Unable to connect to Monitoring."))
        }
      }
    }
    loadSession()->ignore
    Some(() => controller->Fetch.AbortController.abort)
  }, [authStatus])

  let renderError = message =>
    <div className="flex items-center justify-center min-h-96" role="alert">
      <p className="text-sm text-nd_gray-600 dark:text-white"> {message->React.string} </p>
    </div>

  <div className="w-full min-w-0" id="monitoring-screen">
    <PageUtils.PageHeading
      title={destination->MonitoringUtils.getTitle}
      customHeadingStyle="mb-4"
      customTitleStyle="dark:text-white"
    />
    {switch screenState {
    | Loading => <PageLoaderWrapper.ScreenLoader />
    | Failed(message) => renderError(message)
    | Ready(url) =>
      switch MonitoringUtils.getEmbedUrl(~embedUrl=url, ~theme) {
      | None => renderError("Monitoring returned a URL outside the approved gateway.")
      | Some(src) =>
        <iframe
          key=src
          title={destination->MonitoringUtils.getTitle}
          src
          className="w-full border-0 rounded-lg"
          style={ReactDOM.Style.make(~height="calc(100vh - 180px)", ~minHeight="480px", ())}
        />
      }
    }}
  </div>
}
