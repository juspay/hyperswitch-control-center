@react.component
let make = () => {
  // Need to be moved into vault container
  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    if showSideBar {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/vault/home"))
    }
  }

  React.useEffect0(() => {
    goToLanding()
    None
  })

  <VaultContainer />
}
