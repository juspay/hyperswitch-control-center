@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let pageViewEvent = MixpanelHook.usePageView()
  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let path = url.path->List.toArray->Array.joinWith("/")
  React.useEffect(() => {
    if featureFlagDetails.mixpanel {
      pageViewEvent(~path)->ignore
    }
    None
  }, (featureFlagDetails.mixpanel, path))

  {
    switch url.path->urlPath {
    | list{"v2", "recon", "onboarding"} => <ReconOnBoardingContainer />
    | list{"v2", "recon", "configuration"} => <ReconConfigurationContainer />
    | list{"v2", "recon", "home"} => <ReconHomeContainer />
    | list{"v2", "recon", "analytics"} => <ReconAnalyticsContainer />
    | list{"v2", "recon", "reports"} => <ReconReportsContainer />
    | _ => React.null
    }
  }
}
