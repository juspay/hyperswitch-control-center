module HyperSwitchEntryComponent = {
  open HyperswitchAtom
  @react.component
  let make = () => {
    open HyperSwitchEntryUtils
    let fetchDetails = APIUtils.useGetMethod()
    let url = RescriptReactRouter.useUrl()
    let (_zone, setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let setFeatureFlag = featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let {getThemesJson} = React.useContext(ThemeProvider.themeContext)
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
        DOMUtils.window._env_ = value
        configureFavIcon(value.urlThemeConfig.faviconUrl)->ignore
        value
      } catch {
      | _ => Exn.raiseError("Error on configuring endpoint")
      }
    }

    let fetchThemeAndDomainFromUrl = () => {
      let params = url.search->LogicUtils.getDictFromUrlSearchParams
      let themeID = params->Dict.get("theme_id")
      let domainUrl = params->Dict.get("domain")

      if themeID->Option.isSome {
        setThemeIdtoStore(themeID->Option.getOr(""))
      }

      if domainUrl->Option.isSome {
        setDomaintoStore(domainUrl->Option.getOr(""))
      }
      let themeId = getThemeIdfromStore()
      (themeId, domainUrl)
    }

    let appendScript = clarityBaseUrl => {
      try {
        open DOMUtils
        let script = createElement(DOMUtils.document, "script")
        let _ = setAttribute(script, "type", "text/javascript")
        let clarityScript = `
        (function(c,l,a,r,i,t,y){
            c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
            t=l.createElement(r);t.async=1;t.src="${clarityBaseUrl}/"+i;
            y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
        })(window, document, "clarity", "script", "riyj0ujf9n");`
        let textNode = DOMUtils.document->DOMUtils.createTextNode(clarityScript)
        script->Webapi.Dom.Element.appendChild(~child=textNode)
        appendHead(script)->ignore
      } catch {
      | _ => Js.log("Error on appending clarity script")
      }
    }

    let fetchConfig = async () => {
      try {
        let (themeId, domain) = fetchThemeAndDomainFromUrl()
        let apiURL = `${GlobalVars.getHostUrlWithBasePath}/config/feature?domain=${domain->Option.getOr(
            "",
          )}` // todo: domain shall be removed from query params later
        let res = await fetchDetails(apiURL)
        let featureFlags = res->FeatureFlagUtils.featureFlagType
        setFeatureFlag(_ => featureFlags)
        let configValues = configEnv(res) // to set initial env
        let _ = await getThemesJson(~themesID=themeId, ~domain)
        // Delay added on Expecting feature flag recoil gets updated
        await HyperSwitchUtils.delay(1000)

        if configValues.clarityBaseUrl->Option.isSome {
          appendScript(configValues.clarityBaseUrl->Option.getOr(""))->ignore
        }

        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => Custom)
      }
    }

    React.useEffect(() => {
      let _ = setSessionData(~key="auth_id", ~searchParams=url.search)
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
