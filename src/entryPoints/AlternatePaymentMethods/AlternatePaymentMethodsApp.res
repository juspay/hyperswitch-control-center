@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    if showSideBar {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v2/alt-payment-methods/home"),
      )
    }
  }

  React.useEffect(() => {
    goToLanding()
    None
  }, [])

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "alt-payment-methods", "home"} => <AlternatePaymentMethodsHome />
    | list{"v2", "alt-payment-methods", "onboarding", ...remainingPath} =>
      <EntityScaffold
        entityName="alt-payment-methods"
        remainingPath
        renderList={() => <AlternatePaymentMethodsOnboarding />}
        renderNewForm={() => <AlternatePaymentMethodsSetup />}
      />
    | _ => React.null
    }
  }
}
