@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let (showOnBoarding, setShowOnBoarding) = React.useState(_ => true)

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recon", "onboarding"} =>
      <ReconOnBoardingContainer showOnBoarding setShowOnBoarding />
    | list{"v2", "recon", "configuration"} => <ReconConfigurationContainer setShowOnBoarding />
    | list{"v2", "recon", "reports"} => <ReconReportsContainer />
    | _ => React.null
    }
  }
}
