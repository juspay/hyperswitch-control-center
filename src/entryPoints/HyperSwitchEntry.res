module HyperSwitchEntryComponent = {
  @react.component
  let make = () => {
    let fetchDetails = APIUtils.useGetMethod()
    let url = RescriptReactRouter.useUrl()
    let (_zone, setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let setFeatureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
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

    let configThemeURL = (~configData: JSON.t, ~themesData: JSON.t, themeFeature) => {
      open LogicUtils
      open HyperSwitchConfigTypes
      try {
        let dict = configData->getDictFromJsonObject->getDictfromDict("endpoints")
        let urlvalues = {
          if !themeFeature {
            let val = {
              faviconUrl: dict->getString("favicon_url", "")->getNonEmptyString,
              logoUrl: dict->getString("logo_url", "")->getNonEmptyString,
            }
            val
          } else {
            let urlsDict = themesData->getDictFromJsonObject->getDictfromDict("urls")
            let val = {
              faviconUrl: urlsDict->getString("faviconUrl", "")->getNonEmptyString,
              logoUrl: urlsDict->getString("logoUrl", "")->getNonEmptyString,
            }
            val
          }
        }
        let value: urlConfig = {
          apiBaseUrl: dict->getString("api_url", ""),
          mixpanelToken: dict->getString("mixpanel_token", ""),
          sdkBaseUrl: dict->getString("sdk_url", "")->getNonEmptyString,
          agreementUrl: dict->getString("agreement_url", "")->getNonEmptyString,
          dssCertificateUrl: dict->getString("dss_certificate_url", "")->getNonEmptyString,
          applePayCertificateUrl: dict
          ->getString("apple_pay_certificate_url", "")
          ->getNonEmptyString,
          agreementVersion: dict->getString("agreement_version", "")->getNonEmptyString,
          reconIframeUrl: dict->getString("recon_iframe_url", "")->getNonEmptyString,
          urlThemeConfig: urlvalues,
        }
        DOMUtils.window._env_ = value
        configureFavIcon(value.urlThemeConfig.faviconUrl)->ignore
      } catch {
      | _ => Exn.raiseError("Error on configuring endpoint")
      }
    }

    let fetchConfig = async () => {
      try {
        open LogicUtils
        let domain = HyperSwitchEntryUtils.getSessionData(~key="domain", ~defaultValue="default")
        let apiURL = `${GlobalVars.getHostUrlWithBasePath}/config/feature?domain=${domain}`
        let res = await fetchDetails(apiURL)
        let featureFlags = res->FeatureFlagUtils.featureFlagType
        setFeatureFlag(_ => featureFlags)
        let themeFeature = featureFlags.themeFeature
        let themeJson = if !themeFeature {
          let dict = res->getDictFromJsonObject->getDictfromDict("theme")
          let defaultStyle = {
            "settings": {
              "colors": {
                "primary": dict->getString("primary_color", ""),
                "sidebar": dict->getString("sidebar_color", ""),
              },
              "buttons": {
                "primary": {
                  "backgroundColor": dict->getString("primary_color", ""),
                  "textColor": dict->getString("primary_color", ""),
                  "hoverBackgroundColor": dict->getString("primary_hover_color", ""),
                },
              },
            },
          }
          let _ = configThemeURL(~configData={res}, ~themesData=JSON.Encode.null, themeFeature)
          defaultStyle->Identity.genericTypeToJson
        } else {
          try {
            // make a API to fetch the theme
            //call configThemeURL with the response of themes api as themesData
            // let _ = configThemeURL(~configData={res}, ~themesData=themesData, themeFeature)
            JSON.Encode.null
          } catch {
          | _ => JSON.Encode.null
          }
        }
        let _ = themeJson->configCustomDomainTheme

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
        <AuthEntry />
      </div>
    </PageLoaderWrapper>
  }
}

let uiConfig: UIConfig.t = HyperSwitchDefaultConfig.config
EntryPointUtils.renderDashboardApp(<HyperSwitchEntryComponent />)
