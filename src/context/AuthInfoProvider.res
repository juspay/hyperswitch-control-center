open HyperSwitchAuthTypes

let defaultContextValue = {
  authStatus: CheckingAuthStatus,
  setAuthStatus: _ => (),
}

let authStatusContext = React.createContext(defaultContextValue)

module Provider = {
  let make = React.Context.provider(authStatusContext)
}

@react.component
let make = (~children, ~featureFlagDetails: FeatureFlagUtils.featureFlag) => {
  let (authStatus, setAuth) = React.useState(_ => CheckingAuthStatus)

  let setAuthStatus = React.useCallback1((newAuthStatus: HyperSwitchAuthTypes.authStatus) => {
    open HSwitchLoginUtils
    switch newAuthStatus {
    | LoggedIn(info) => {
        sptToken(info.token, info.flowType->variantToStringFlowMapper)

        // add feature flag
        // add to accept email from url
        if featureFlagDetails.newAuthEnabled {
          RescriptReactRouter.replace(
            HSwitchGlobalVars.appendDashboardPath(
              ~url=`/${info.flowType->variantToStringFlowMapper}`,
            ),
          )
        }
      }
    | LoggedOut => clearLocalStorage()
    | CheckingAuthStatus => ()
    }
    setAuth(_ => newAuthStatus)
  }, [setAuth])

  <Provider value={authStatus, setAuthStatus}> children </Provider>
}
