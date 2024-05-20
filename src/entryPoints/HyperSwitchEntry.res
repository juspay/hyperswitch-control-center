module HyperSwitchEntryComponent = {
  @react.component
  let make = () => {
    open CommonAuthHooks
    let fetchDetails = APIUtils.useGetMethod()
    let {email, name} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    let url = RescriptReactRouter.useUrl()
    let (_zone, setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let setFeatureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let defaultGlobalConfig: HyperSwitchConfigTypes.customStyle = {
      primaryColor: "#006DF9",
      primaryHover: "#005ED6",
      sidebar: "#242F48",
    }

    let configTheme = (uiConfg: JSON.t) => {
      open LogicUtils
      let dict = uiConfg->getDictFromJsonObject->getDictfromDict("theme")
      let {primaryColor, primaryHover, sidebar} = defaultGlobalConfig
      let value: HyperSwitchConfigTypes.customStyle = {
        primaryColor: dict->getString("primary_color", primaryColor),
        primaryHover: dict->getString("primary_hover_color", primaryHover),
        sidebar: dict->getString("sidebar_color", sidebar),
      }
      Window.appendStyle(value)
    }

    let configureFavIcon = faviconUrl => {
      try {
        open DOMUtils
        let a = createElement(DOMUtils.document, "link")
        let _ = setAttribute(a, "href", `${faviconUrl}`)
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
          mixpanelToken: dict->getString("mixpanelToken", ""),
          faviconUrl: dict->getString("favicon_url", "/HyperswitchFavicon.png"),
          logoUrl: dict->getString("logo_url", "")->getNonEmptyString,
          sdkBaseUrl: dict->getString("sdk_url", "")->getNonEmptyString,
        }
        DOMUtils.window._env_ = value
        configureFavIcon(value.faviconUrl)->ignore
      } catch {
      | _ => Exn.raiseError("Error on configuring endpoint")
      }
    }
    // Need to modify based on the usedcase
    let getDomain = () => {
      SessionStorage.getItemFromSession("domain")->LogicUtils.getValFromNullableValue("default")
    }

    let fetchConfig = async () => {
      try {
        let domain = getDomain()
        let apiURL = `${HSwitchGlobalVars.getHostUrlWithBasePath}/config/merchant-config?domain=${domain}`
        let res = await fetchDetails(apiURL)
        let featureFlags = res->FeatureFlagUtils.featureFlagType
        setFeatureFlag(._ => featureFlags)
        let _ = res->configTheme
        let _ = res->configURL
        // Delay added on Expecting feature flag recoil gets updated
        await HyperSwitchUtils.delay(1000)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => Custom)
      }
    }

    React.useEffect0(() => {
      let _ = fetchConfig()->ignore
      None
    })
    React.useEffect0(() => {
      HSiwtchTimeZoneUtils.getUserTimeZone()->setZone
      None
    })

    React.useEffect3(() => {
      MixPanel.init(
        Window.env.mixpanelToken,
        {
          "batch_requests": true,
          "loaded": () => {
            let mixpanelUserInfo =
              [("name", email->JSON.Encode.string), ("merchantName", name->JSON.Encode.string)]
              ->Dict.fromArray
              ->JSON.Encode.object

            let userId = MixPanel.getDistinctId()
            LocalStorage.setItem("deviceid", userId)
            MixPanel.identify(userId)
            MixPanel.mixpanel.people.set(. mixpanelUserInfo)
          },
        },
      )
      None
    }, (name, email, Window.env.mixpanelToken))

    let setPageName = pageTitle => {
      let page = pageTitle->LogicUtils.snakeToTitle
      let title = featureFlagDetails.isLiveMode
        ? `${page} - Dashboard`
        : `${page} - Dashboard [Test]`
      DOMUtils.document.title = title
      GoogleAnalytics.send({hitType: "pageview", page})
    }

    React.useEffect1(() => {
      switch url.path {
      | list{"user", "verify_email"} => "verify_email"->setPageName
      | list{"user", "set_password"} => "set_password"->setPageName
      | list{"user", "login"} => "magic_link_verify"->setPageName
      | _ =>
        switch List.head(url.path) {
        | Some(pageTitle) => pageTitle->setPageName
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
          <TotpAuthEntry />
        } else {
          <BasicAuthEntry />
        }}
      </div>
    </PageLoaderWrapper>
  }
}

let uiConfig: UIConfig.t = HyperSwitchDefaultConfig.config
EntryPointUtils.renderDashboardApp(<HyperSwitchEntryComponent />)
