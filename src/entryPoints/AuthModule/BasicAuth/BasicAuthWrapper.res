@react.component
let make = (~children) => {
  let url = RescriptReactRouter.useUrl()
  let {authStatus, setAuthStatus, setAuthStateToLogout} = React.useContext(
    AuthInfoProvider.authStatusContext,
  )

  React.useEffect(() => {
    switch url.path {
    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "accept_invite_from_email"}
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStateToLogout()
    | _ => {
        let authInfo = BasicAuthUtils.getBasicAuthInfoFromStrorage()
        switch authInfo.token {
        | Some(_) => setAuthStatus(LoggedIn(BasicAuth(authInfo)))
        | None => setAuthStateToLogout()
        }
      }
    }
    None
  }, [])

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut => <BasicAuthScreen />
    | PreLogin(_)
    | LoggedIn(_) => children
    | CheckingAuthStatus => <Loader />
    }}
  </div>
}
