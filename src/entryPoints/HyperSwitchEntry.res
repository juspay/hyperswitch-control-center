module HyperSwitchEntryComponent = {
  @react.component
  let make = () => {
    let fetchDetails = APIUtils.useGetMethod()
    let url = RescriptReactRouter.useUrl()
    let (_zone, setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let setFeatureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let {configCustomDomainTheme} = React.useContext(ThemeProvider.themeContext)

    let configureFavIcon = (faviconUrl: option<string>) => {
      try {
        open DOMUtils
        let a = createElement(DOMUtils.document, "link")
        let _ = setAttribute(a, "href", `${faviconUrl->Option.getOr("/HyperswitchFavicon.png")}`)
        let _ = setAttribute(a, "rel", "shortcut icon")
        let _ = setAttribute(a, "type", "image/x-icon")
        let _ = appendHead(a)
      } catch {
      | _ => Exn.raiseError("Error on configuring favicon")
      }
    }

    let configURL = (urlConfig: JSON.t) => {
      open LogicUtils
      open HyperSwitchConfigTypes
      try {
        let dict = urlConfig->getDictFromJsonObject->getDictfromDict("endpoints")
        let value: urlConfig = {
          apiBaseUrl: dict->getString("api_url", ""),
          mixpanelToken: dict->getString("mixpanel_token", ""),
          faviconUrl: dict->getString("favicon_url", "")->getNonEmptyString,
          logoUrl: dict->getString("logo_url", "")->getNonEmptyString,
          sdkBaseUrl: dict->getString("sdk_url", "")->getNonEmptyString,
          agreementUrl: dict->getString("agreement_url", "")->getNonEmptyString,
          applePayCertificateUrl: dict
          ->getString("apple_pay_certificate_url", "")
          ->getNonEmptyString,
          agreementVersion: dict->getString("agreement_version", "")->getNonEmptyString,
          reconIframeUrl: dict->getString("recon_iframe_url", "")->getNonEmptyString,
        }
        DOMUtils.window._env_ = value
        configureFavIcon(value.faviconUrl)->ignore
      } catch {
      | _ => Exn.raiseError("Error on configuring endpoint")
      }
    }
    // Need to modify based on the usedcase

    let fetchConfig = async () => {
      try {
        let domain = HyperSwitchEntryUtils.getSessionData(
          ~key="domain",
          ~defaultValue="default",
          (),
        )
        let apiURL = `${GlobalVars.getHostUrlWithBasePath}/config/merchant-config?domain=${domain}`
        let res = await fetchDetails(apiURL)
        let featureFlags = res->FeatureFlagUtils.featureFlagType
        setFeatureFlag(_ => featureFlags)
        let _ = res->configCustomDomainTheme
        let _ = res->configURL
        // Delay added on Expecting feature flag recoil gets updated
        await HyperSwitchUtils.delay(1000)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => Custom)
      }
    }

    React.useEffect(() => {
      let _ = HyperSwitchEntryUtils.setSessionData(~key="auth_id", ~searchParams=url.search)
      let _ = HyperSwitchEntryUtils.setSessionData(~key="domain", ~searchParams=url.search)

      let _ = fetchConfig()->ignore
      None
    }, [])
    React.useEffect(() => {
      TimeZoneUtils.getUserTimeZone()->setZone
      None
    }, [])

    React.useEffect(() => {
      if featureFlagDetails.mixpanel {
        MixPanel.init(
          Window.env.mixpanelToken,
          {
            "track_pageview": true,
            "batch_requests": true,
            "loaded": () => {
              let userId = MixPanel.getDistinctId()
              LocalStorage.setItem("deviceid", userId)
            },
          },
        )
      }

      None
    }, Window.env.mixpanelToken)

    let setPageName = pageTitle => {
      let page = pageTitle->LogicUtils.snakeToTitle
      let title = `${page} - Dashboard`
      DOMUtils.document.title = title
      GoogleAnalytics.send({hitType: "pageview", page})
    }

    React.useEffect(() => {
      switch url.path {
      | list{"user", "verify_email"} => "verify_email"->setPageName
      | list{"user", "set_password"} => "set_password"->setPageName
      | list{"user", "login"} => "magic_link_verify"->setPageName
      | _ =>
        switch url.path->List.drop(1) {
        | Some(val) =>
          switch List.head(val) {
          | Some(pageTitle) => pageTitle->setPageName
          | _ => ()
          }
        | _ => ()
        }
      }
      None
    }, [url.path])
    <PageLoaderWrapper
      screenState
      sectionHeight="h-screen"
      customUI={<NoDataFound message="Oops! Missing config" renderType=NotFound />}>
      <div className="text-black">
        {if featureFlagDetails.totp {
          <AuthEntry />
        } else {
          <BasicAuthEntry />
        }}
      </div>
    </PageLoaderWrapper>
  }
}

let uiConfig: UIConfig.t = HyperSwitchDefaultConfig.config
EntryPointUtils.renderDashboardApp(<HyperSwitchEntryComponent />)
