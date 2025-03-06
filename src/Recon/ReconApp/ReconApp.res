@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let (showOnBoarding, setShowOnBoarding) = React.useState(_ => true)

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recon"} => <ReconOnBoardingContainer showOnBoarding />
    | list{"v2", "recon", "home"} => <ReconConfigurationContainer setShowOnBoarding />
    | list{"v2", "recon", "reports", ..._} => <ReconReportsContainer />
    | _ => React.null
    }
  }
}
