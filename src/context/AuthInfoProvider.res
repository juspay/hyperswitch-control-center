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
        | Some(token) =>
          if !(token->LogicUtils.isEmptyString) {
            setAuth(_ => newAuthStatus)
            BasicAuthUtils.setBasicAuthResToStorage(basicInfo)
          } else {
            setAuth(_ => LoggedOut)
            CommonAuthUtils.clearLocalStorage()
          }
        | None => {
            setAuth(_ => LoggedOut)
            CommonAuthUtils.clearLocalStorage()
          }
        }
      | Auth(totpInfo) =>
        if totpInfo.token->Option.isSome {
          setAuth(_ => newAuthStatus)
          AuthUtils.setDetailsToLocalStorage(totpInfo, "USER_INFO")
        } else {
          setAuth(_ => LoggedOut)
          CommonAuthUtils.clearLocalStorage()
        }
      }
    | PreLogin(preLoginInfo) =>
      setAuth(_ => newAuthStatus)
      AuthUtils.setDetailsToLocalStorage(preLoginInfo, "PRE_LOGIN_INFO")

    | LoggedOut => {
        setAuth(_ => LoggedOut)
        CommonAuthUtils.clearLocalStorage()
        AuthUtils.redirectToLogin()
      }
    | CheckingAuthStatus => setAuth(_ => CheckingAuthStatus)
    }
  }, [setAuth])

  let setAuthStateToLogout = React.useCallback0(() => {
    setAuth(_ => LoggedOut)
    CommonAuthUtils.clearLocalStorage()
  })

  <Provider value={authStatus, setAuthStatus, setAuthStateToLogout}> children </Provider>
}
