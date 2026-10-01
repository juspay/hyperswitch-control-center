open MonitoringUtils

@react.component
let make = (~destination) => {
  let bootstrap = MonitoringHooks.useGrafanaSession()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (embedUrl, setEmbedUrl) = React.useState(_ => "")
  let (errorMessage, setErrorMessage) = React.useState(_ => "")

  let showError = message => {
    setErrorMessage(_ => message)
    setScreenState(_ => PageLoaderWrapper.Custom)
  }

  let loadSession = async () => {
    try {
      switch await bootstrap(~destination) {
      | Result.Ok(url) =>
        setEmbedUrl(_ => url)
        setScreenState(_ => PageLoaderWrapper.Success)
      | Result.Error(message) => showError(message)
      }
    } catch {
    | _ => showError("Unable to connect to Monitoring.")
    }
  }

  React.useEffect0(() => {
    loadSession()->ignore
    None
  })

  let errorUI =
    <div className="flex items-center justify-center min-h-96" role="alert">
      <p className={`${Typography.body.sm.regular} text-nd_gray-600 dark:text-white`}>
        {errorMessage->React.string}
      </p>
    </div>

  <div className="w-full min-w-0" id="monitoring-screen">
    <PageUtils.PageHeading
      title={destination->getTitle} customHeadingStyle="mb-4" customTitleStyle="dark:text-white"
    />
    <PageLoaderWrapper screenState customUI=errorUI>
      <iframe
        title={destination->getTitle}
        src=embedUrl
        className="w-full border-0 rounded-lg"
        style={ReactDOM.Style.make(~height="calc(100vh - 180px)", ~minHeight="480px", ())}
      />
    </PageLoaderWrapper>
  </div>
}
