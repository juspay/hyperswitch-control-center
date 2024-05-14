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
      | BasicAuth(basicInfo) =>
        switch basicInfo.token {
        | Some(token) => {
            Js.log2("token", token)
            if !(token->LogicUtils.isEmptyString) {
              setAuth(_ => newAuthStatus)
            } else {
              setAuth(_ => LoggedOut)
              CommonAuthUtils.clearLocalStorage()
            }
          }
        | None => {
            setAuth(_ => LoggedOut)
            CommonAuthUtils.clearLocalStorage()
          }
        }
      | ToptAuth(totpInfo) =>
        switch totpInfo.token {
        | Some(token) => {
            setAuth(_ => newAuthStatus)
            TotpUtils.sptToken(token, totpInfo.token_type->TotpUtils.variantToStringFlowMapper)
          }
        | None => {
            setAuth(_ => LoggedOut)
            CommonAuthUtils.clearLocalStorage()
          }
        }
      }

    | LoggedOut => {
        setAuth(_ => LoggedOut)
        CommonAuthUtils.clearLocalStorage()
      }
    | CheckingAuthStatus => {
        setAuth(_ => CheckingAuthStatus)
        CommonAuthUtils.clearLocalStorage()
      }
    }
  }, [setAuth])

  let setAuthStateToLogout = React.useCallback0(() => {
    setAuth(_ => LoggedOut)
  })

  <Provider value={authStatus, setAuthStatus, setAuthStateToLogout}> children </Provider>
}
