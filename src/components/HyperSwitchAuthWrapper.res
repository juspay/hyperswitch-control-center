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
    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStatus(LoggedOut)
    | _ =>
      switch LocalStorage.getItem("login")->Js.Nullable.toOption {
      | Some(token) =>
        if !(token->HSwitchUtils.isEmptyString) {
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
