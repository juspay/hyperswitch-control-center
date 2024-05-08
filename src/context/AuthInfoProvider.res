type authType = BasicAuth(BasicAuthTypes.basicAuthInfo) | ToptAuth(ToptTypes.totpAuthInfo)

type authStatus = LoggedOut | LoggedIn(authType) | CheckingAuthStatus

type defaultProviderTypes = {
  authStatus: authStatus,
  setAuthStatus: authStatus => unit,
  setAuthStateToLogout: unit => unit,
}
let defaultContextValue = {
  authStatus: CheckingAuthStatus,
  setAuthStatus: _ => (),
  setAuthStateToLogout: _ => (),
}

let authStatusContext = React.createContext(defaultContextValue)

module Provider = {
  let make = React.Context.provider(authStatusContext)
}

@react.component
let make = (~children) => {
  let (authStatus, setAuth) = React.useState(_ => CheckingAuthStatus)

  let setAuthStatus = React.useCallback1((newAuthStatus: authStatus) => {
    switch newAuthStatus {
    | LoggedIn(info) =>
      switch info {
      | BasicAuth(basicInfo) => LocalStorage.setItem("login", basicInfo.token)
      | ToptAuth(totpInfo) => LocalStorage.setItem("login", totpInfo.token)
      }

    | LoggedOut
    | CheckingAuthStatus => ()
    }
    setAuth(_ => newAuthStatus)
  }, [setAuth])

  let setAuthStateToLogout = React.useCallback0(() => {
    setAuth(_ => LoggedOut)
  })

  <Provider value={authStatus, setAuthStatus, setAuthStateToLogout}> children </Provider>
}
