open HyperSwitchAuthTypes
@react.component
let make = (~children) => {
  let url = RescriptReactRouter.useUrl()
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  React.useEffect0(() => {
    switch url.path {
    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "accept_invite_from_email"}
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStatus(LoggedOut)
    | _ =>
      switch LocalStorage.getItem("login")->Nullable.toOption {
      | Some(token) =>
        if !(token->LogicUtils.isEmptyString) {
          setAuthStatus(LoggedIn(HyperSwitchAuthTypes.getDummyAuthInfoForToken(token)))
        } else {
          setAuthStatus(LoggedOut)
        }
      | None => setAuthStatus(LoggedOut)
      }
    }

    None
  })

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut => <HyperSwitchAuthScreen setAuthStatus />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <Loader />
    }}
  </div>
}
