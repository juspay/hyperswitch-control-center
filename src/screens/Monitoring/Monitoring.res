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

  let loadSession = async isActive => {
    try {
      let result = await bootstrap(~destination)
      if isActive.contents {
        setScreenState(_ => result)
      }
    } catch {
    | _ =>
      if isActive.contents {
        setScreenState(_ => Failed("Unable to connect to Monitoring."))
      }
    }
  }

  React.useEffect(() => {
    let isActive = ref(true)
    setScreenState(_ => Loading)
    loadSession(isActive)->ignore
    Some(() => isActive.contents = false)
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
    | Loading => <Loader />
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
