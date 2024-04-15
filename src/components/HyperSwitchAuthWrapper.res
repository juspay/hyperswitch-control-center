open HyperSwitchAuthTypes
@react.component
let make = (~children) => {
  let url = RescriptReactRouter.useUrl()
  let (currentAuthState, setCurrentAuthState) = React.useState(_ => CheckingAuthStatus)

  let setAuthStatus = React.useCallback1((newAuthStatus: HyperSwitchAuthTypes.authStatus) => {
    switch newAuthStatus {
    | LoggedIn(info) => LocalStorage.setItem("login", info.token)
    | LoggedOut
    | CheckingAuthStatus => ()
    }
    setCurrentAuthState(_ => newAuthStatus)
  }, [setCurrentAuthState])

  React.useEffect0(() => {
    switch url.path {
    | list{"dashboard", "user", "verify_email"}
    | list{"dashboard", "user", "set_password"}
    | list{"dashboard", "user", "accept_invite_from_email"}
    | list{"dashboard", "user", "login"}
    | list{"dashboard", "register"} =>
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
    <AuthInfoProvider value={(currentAuthState, setAuthStatus)}>
      {switch currentAuthState {
      | LoggedOut => <HyperSwitchAuthScreen setAuthStatus />
      | LoggedIn(_token) => children
      | CheckingAuthStatus => <Loader />
      }}
    </AuthInfoProvider>
  </div>
}
