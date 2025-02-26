@react.component
let make = (~setShowOnBoarding) => {
  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    if showSideBar {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/onboarding"))
    }
  }

  React.useEffect0(() => {
    goToLanding()
    None
  })

  <ReconConfiguration setShowOnBoarding />
}
