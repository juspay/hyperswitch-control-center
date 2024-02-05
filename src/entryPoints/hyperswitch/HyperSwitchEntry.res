module HyperSwitchEntryComponent = {
  @react.component
  let make = () => {
    open HSLocalStorage
    let postDetails = APIUtils.useUpdateMethod()
    let email = getFromMerchantDetails("email")
    let name = getFromUserDetails("name")
    let url = RescriptReactRouter.useUrl()
    let (_zone, setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let setFeatureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    React.useEffect0(() => {
      HSiwtchTimeZoneUtils.getUserTimeZone()->setZone
      None
    })

    React.useEffect2(() => {
      MixPanel.init(
        HSwitchGlobalVars.mixpanelToken,
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
    }, (name, email))

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

    let fetchFeatureFlags = async () => {
      try {
        let url = `${HSwitchGlobalVars.hyperSwitchFEPrefix}/config/merchant-access`
        let typedResponse =
          (
            await postDetails(url, Dict.make()->JSON.Encode.object, Post, ())
          )->FeatureFlagUtils.featureFlagType
        setFeatureFlag(._ => typedResponse)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Something went wrong!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }

    React.useEffect0(() => {
      fetchFeatureFlags()->ignore
      None
    })

    <PageLoaderWrapper screenState sectionHeight="h-screen">
      <div className="text-black">
        <HyperSwitchAuthWrapper>
          <GlobalProvider>
            <DecisionScreen />
          </GlobalProvider>
        </HyperSwitchAuthWrapper>
      </div>
    </PageLoaderWrapper>
  }
}

let uiConfig: UIConfig.t = HyperSwitchDefaultConfig.config
EntryPointUtils.renderDashboardApp(<HyperSwitchEntryComponent />, ~uiConfig)
