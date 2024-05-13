open AuthProviderTypes

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
      // Re-Check
      | BasicAuth(basicInfo) =>
        switch basicInfo.token {
        | Some(token) => LocalStorage.setItem("login", token)
        | None => CommonAuthUtils.clearLocalStorage()
        }
      | ToptAuth(totpInfo) =>
        switch totpInfo.token {
        | Some(token) =>
          TotpUtils.sptToken(token, totpInfo.token_type->TotpUtils.variantToStringFlowMapper)
        | None => CommonAuthUtils.clearLocalStorage()
        }
      }

    | LoggedOut => CommonAuthUtils.clearLocalStorage()
    | CheckingAuthStatus => ()
    }
    setAuth(_ => newAuthStatus)
  }, [setAuth])

  let setAuthStateToLogout = React.useCallback0(() => {
    setAuth(_ => LoggedOut)
  })

  <Provider value={authStatus, setAuthStatus, setAuthStateToLogout}> children </Provider>
}
