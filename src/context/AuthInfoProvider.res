open AuthProviderTypes

type defaultProviderTypes = {
  authStatus: authStatus,
  setAuthStatus: authStatus => unit,
  setAuthStateToLogout: unit => unit,
  setAuthMethods: (
    array<SSOTypes.authMethodResponseType> => array<SSOTypes.authMethodResponseType>
  ) => unit,
  authMethods: array<SSOTypes.authMethodResponseType>,
}
let defaultContextValue = {
  authStatus: CheckingAuthStatus,
  setAuthStatus: _ => (),
  setAuthStateToLogout: _ => (),
  setAuthMethods: _ => (),
  authMethods: AuthUtils.defaultListOfAuth,
}

let authStatusContext = React.createContext(defaultContextValue)

module Provider = {
  let make = React.Context.provider(authStatusContext)
}

@react.component
let make = (~children) => {
  let (authStatus, setAuth) = React.useState(_ => CheckingAuthStatus)
  let (authMethods, setAuthMethods) = React.useState(_ => [])
  let setAuthStatus = React.useCallback((newAuthStatus: authStatus) => {
    switch newAuthStatus {
    | LoggedIn(info) =>
      switch info {
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

  let setAuthStateToLogout = React.useCallback(() => {
    setAuth(_ => LoggedOut)
    CommonAuthUtils.clearLocalStorage()
    CookieStorage.deleteCookie(~cookieName="login_token", ~domain=GlobalVars.hostName)
  }, [])

  <Provider
    value={
      authStatus,
      setAuthStatus,
      setAuthStateToLogout,
      setAuthMethods,
      authMethods,
    }>
    children
  </Provider>
}
