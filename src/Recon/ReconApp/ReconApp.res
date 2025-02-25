@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let (showOnBoarding, setShowOnBoarding) = React.useState(_ => true)
  let (showSkeleton, setShowSkeleton) = React.useState(_ => true)

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recon", "onboarding"} =>
      <ReconOnBoardingContainer showOnBoarding setShowOnBoarding showSkeleton />
    | list{"v2", "recon", "configuration"} =>
      <ReconConfigurationContainer setShowOnBoarding setShowSkeleton />
    | list{"v2", "recon", "reports"} => <ReconReportsContainer />
    | _ => React.null
    }
  }
}
