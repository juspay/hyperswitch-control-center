@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recon", "onboarding"} => <ReconOnBoardingContainer />
    | list{"v2", "recon", "configuration"} => <ReconConfigurationContainer />
    | list{"v2", "recon", "home"} => <ReconHomeContainer />
    | list{"v2", "recon", "analytics"} => <ReconAnalyticsContainer />
    | list{"v2", "recon", "reports"} => <ReconReportsContainer />
    | list{"v2", "recon", "run-recon"} => <ReconHistoryContainer />
    | _ => React.null
    }
  }
}
