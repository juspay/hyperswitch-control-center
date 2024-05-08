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
let make = (~children) => {
  let (authStatus, setAuth) = React.useState(_ => CheckingAuthStatus)

  let setAuthStatus = React.useCallback1((newAuthStatus: HyperSwitchAuthTypes.authStatus) => {
    switch newAuthStatus {
    | LoggedIn(info) => LocalStorage.setItem("login", info.token)
    | LoggedOut
    | CheckingAuthStatus => ()
    }
    setAuth(_ => newAuthStatus)
  }, [setAuth])

  <Provider value={{authStatus, setAuthStatus}}> children </Provider>
}
