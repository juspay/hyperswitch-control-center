module EmbeddableAuthEntry = {
  @react.component
  let make = () => {
    <GlobalProvider>
      <UserInfoProvider isEmbeddableApp=true>
        <EmbeddableApp />
      </UserInfoProvider>
    </GlobalProvider>
  }
}

module EmbeddableEntryComponent = {
  @react.component
  let make = () => {
    let fetchDetails = APIUtils.useGetMethod()
    let setFeatureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let configEnv = (urlConfig: JSON.t) => {
      open LogicUtils
      open HyperSwitchConfigTypes
      try {
        let dict = urlConfig->getDictFromJsonObject->getDictfromDict("endpoints")
        let value: urlConfig = {
          apiBaseUrl: dict->getString("api_url", ""),
          mixpanelToken: dict->getString("mixpanel_token", ""),
          sdkBaseUrl: dict->getString("sdk_url", "")->getNonEmptyString,
          agreementUrl: dict->getString("agreement_url", "")->getNonEmptyString,
          dssCertificateUrl: dict->getString("dss_certificate_url", "")->getNonEmptyString,
          dynamoSimulationTemplateUrl: dict
          ->getString("dynamo_simulation_template_url", "")
          ->getNonEmptyString,
          applePayCertificateUrl: dict
          ->getString("apple_pay_certificate_url", "")
          ->getNonEmptyString,
          agreementVersion: dict->getString("agreement_version", "")->getNonEmptyString,
          reconIframeUrl: dict->getString("recon_iframe_url", "")->getNonEmptyString,
          urlThemeConfig: {
            faviconUrl: dict->getString("favicon_url", "")->getNonEmptyString,
            logoUrl: dict->getString("logo_url", "")->getNonEmptyString,
          },
          hypersenseUrl: dict->getString("hypersense_url", ""),
          clarityBaseUrl: dict->getString("clarity_base_url", "")->getNonEmptyString,
        }
        Js.log2("DOMUtils.window", DOMUtils.window)
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

@val @return(nullable)
external getElementById: string => option<Dom.element> = "document.getElementById"

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
      </ErrorBoundary>
    </React.Suspense>
  }
}

let renderDashboardAppLibrary = children => {
  Js.log2("inside renderDashboardAppLibrary", getElementById("app"))
  switch getElementById("app") {
  | Some(container) =>
    open ReactDOM.Client
    open ReactDOM.Client.Root

    let root = createRoot(container)
    root->render(<ContextWrapper> {children} </ContextWrapper>)
  | None => Console.error("Could not find element with id 'app' to render the application")
  }
}

renderDashboardAppLibrary(<EmbeddableEntryComponent />)
