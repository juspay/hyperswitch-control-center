let getAccessibleColor = hex => {
  let color = if hex->String.replaceRegExp(%re("/\./g"), "")->String.length !== 6 {
    `${hex->String.replaceRegExp(%re("/\./g"), "")}${hex->String.replaceRegExp(%re("/\./g"), "")}`
  } else {
    hex->String.replaceRegExp(%re("/\./g"), "")
  }
  let r = color->String.substring(~start=0, ~end=2)->Int.fromString(~radix=16)->Option.getOr(0)
  let g = color->String.substring(~start=2, ~end=2)->Int.fromString(~radix=16)->Option.getOr(0)
  let b = color->String.substring(~start=4, ~end=2)->Int.fromString(~radix=16)->Option.getOr(0)
  let yiq = (r * 299 + g * 587 + b * 114) / 1000
  yiq >= 128 ? "#000000" : "#FFFFFF"
}

let getRGBColor = (hex, \"type") => {
  let color = if hex->String.replaceRegExp(%re("/\./g"), "")->String.length !== 6 {
    `${hex->String.replaceRegExp(%re("/\./g"), "")}${hex->String.replaceRegExp(%re("/\./g"), "")}`
  } else {
    hex->String.replaceRegExp(%re("/\./g"), "")
  }
  let r = color->String.substring(~start=0, ~end=2)->Int.fromString(~radix=16)->Option.getOr(0)
  let g = color->String.substring(~start=2, ~end=2)->Int.fromString(~radix=16)->Option.getOr(0)
  let b = color->String.substring(~start=4, ~end=2)->Int.fromString(~radix=16)->Option.getOr(0)
  `--color-${\"type"}: ${Belt.Int.toString(r)}, ${Belt.Int.toString(g)}, ${Belt.Int.toString(b)};`
}

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

    React.useEffect0(() => {
      let customStyle: Window.customStyle = {
        primaryColor: "#22c55e",
        primaryHover: "#facc15",
        sidebar: "#b91c1c",
      }
      let _ = Window.appendStyle(customStyle)
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
EntryPointUtils.renderDashboardApp(<HyperSwitchEntryComponent />)
