module EmbeddableAuthEntry = {
  @react.component
  let make = () => {
    <EmbeddedCheckProvider>
      <GlobalProvider>
        <UserInfoProvider isEmbeddableApp=true>
          <EmbeddableApp />
        </UserInfoProvider>
      </GlobalProvider>
    </EmbeddedCheckProvider>
  }
}

module EmbeddableEntryComponent = {
  @react.component
  let make = () => {
    let fetchDetails = APIUtils.useGetMethod()
    let setFeatureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let {getThemesJson} = React.useContext(ThemeProvider.themeContext)

    let configEnv = (urlConfig: JSON.t) => {
      open LogicUtils
      try {
        let dict = urlConfig->getDictFromJsonObject->getDictfromDict("endpoints")
        let value = dict->EmbeddableGlobalUtils.getConfigFromDict
        DOMUtils.window._env_ = value
        setScreenState(_ => PageLoaderWrapper.Success)
        value
      } catch {
      | _ => Exn.raiseError("Error on configuring endpoint")
      }
    }

    let fetchConfig = async () => {
      try {
        let apiURL = `${GlobalVars.getHostUrlWithBasePath}/config/feature?domain=""` // todo: domain shall be removed from query params later
        let res = await fetchDetails(apiURL)
        let featureFlags = res->FeatureFlagUtils.featureFlagType
        setFeatureFlag(_ => featureFlags)
        let _ = configEnv(res) // to set initial env
        let _ = await getThemesJson(~themesID=None, ~domain=None)

        // Delay added on Expecting feature flag recoil gets updated
        await HyperSwitchUtils.delay(1000)

        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => Custom)
      }
    }

    React.useEffect(() => {
      let _ = fetchConfig()->ignore
      None
    }, [])

    <PageLoaderWrapper screenState>
      <div className={`h-full w-full`}>
        <EmbeddableAuthEntry />
      </div>
    </PageLoaderWrapper>
  }
}

module ContextWrapper = {
  %%raw(`require("tailwindcss/tailwind.css")`)
  @react.component
  let make = (~children) => {
    let loader =
      <div className={`h-screen w-screen flex justify-center items-center`}>
        <Loader />
      </div>

    <React.Suspense fallback={loader}>
      <ErrorBoundary renderFallback={_ => <div> {React.string("Error")} </div>}>
        <ThemeProvider>
          <Recoil.RecoilRoot>
            <ErrorBoundary>
              <PopUpContainer>
                <SnackBarContainer>
                  <ToastContainer>
                    <ModalContainer> {children} </ModalContainer>
                  </ToastContainer>
                </SnackBarContainer>
              </PopUpContainer>
            </ErrorBoundary>
          </Recoil.RecoilRoot>
        </ThemeProvider>
      </ErrorBoundary>
    </React.Suspense>
  }
}

let renderDashboardAppLibrary = children => {
  switch ReactDOM.querySelector("#app") {
  | Some(container) =>
    open ReactDOM.Client
    open ReactDOM.Client.Root

    let root = createRoot(container)
    root->render(<ContextWrapper> {children} </ContextWrapper>)
  | None => Console.error("Could not find element with id 'app' to render the application")
  }
}

renderDashboardAppLibrary(<EmbeddableEntryComponent />)
