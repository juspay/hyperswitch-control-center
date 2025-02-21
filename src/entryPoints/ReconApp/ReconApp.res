@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let (showOnBoarding, setShowOnBoarding) = React.useState(_ => true)
  let (showSkeleton, setShowSkeleton) = React.useState(_ => true)

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recon", "onboarding"} =>
      <ReconOnBoardingContainer showOnBoarding setShowOnBoarding showSkeleton setShowSkeleton />
    | list{"v2", "recon", "configuration"} =>
      <ReconConfigurationContainer setShowOnBoarding setShowSkeleton />
    | list{"v2", "recon", "home"} => <ReconHomeContainer />
    | list{"v2", "recon", "analytics"} => <ReconAnalyticsContainer />
    | list{"v2", "recon", "reports"} => <ReconReportsContainer />
    | list{"v2", "recon", "run-recon"} => <ReconHistoryContainer />
    | _ => React.null
    }
  }
}
