open HyperSwitchAuthTypes

type defaultProviderTypes = {
  currentAuthState: authStatus,
  setAuthStatus: authStatus => unit,
  flowType: flowType,
  setFlow: flowType => unit,
}

let defaultContextValue = {
  currentAuthState: CheckingAuthStatus,
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
  let (currentAuthState, setCurrentAuthState) = React.useState(_ => CheckingAuthStatus)
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
    setCurrentAuthState(_ => newAuthStatus)
  }, [setCurrentAuthState])

  let setFlow = React.useCallback1(flowType => {
    setFlowType(_ => flowType)
  }, [setFlowType])

  <Provider value={{currentAuthState, setAuthStatus, flowType, setFlow}}> children </Provider>
}
