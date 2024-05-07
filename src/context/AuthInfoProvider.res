open HyperSwitchAuthTypes

type defaultProviderTypes = {
  authStatus: authStatus,
  setAuthStatus: authStatus => unit,
  flowType: flowType,
  setFlow: flowType => unit,
}

let defaultContextValue = {
  authStatus: CheckingAuthStatus,
  setAuthStatus: _ => (),
  flowType: ERROR,
  setFlow: _ => (),
}

let authStatusContext = React.createContext(defaultContextValue)

module Provider = {
  let make = React.Context.provider(authStatusContext)
}

@react.component
let make = (~children) => {
  let (authStatus, setAuth) = React.useState(_ => CheckingAuthStatus)
  let (flowType, setFlowType) = React.useState(_ =>
    Some(
      HSLocalStorage.getFromUserDetails("token_type"),
    )->HSwitchLoginUtils.flowTypeStrToVariantMapper
  )

  let setAuthStatus = React.useCallback1((newAuthStatus: HyperSwitchAuthTypes.authStatus) => {
    switch newAuthStatus {
    | LoggedIn(info) => LocalStorage.setItem("login", info.token)
    | LoggedOut
    | CheckingAuthStatus => ()
    }
    setAuth(_ => newAuthStatus)
  }, [setAuth])

  let setFlow = React.useCallback1(flowType => {
    setFlowType(_ => flowType)
  }, [setFlowType])

  <Provider value={{authStatus, setAuthStatus, flowType, setFlow}}> children </Provider>
}
