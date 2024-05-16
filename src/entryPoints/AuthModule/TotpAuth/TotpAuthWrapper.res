@react.component
let make = (~children) => {
  open APIUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let authLogic = () => {
    open TotpUtils
    let authInfo = getTotputhInfoFromStrorage()
    switch authInfo.token {
    | Some(_) => setAuthStatus(LoggedIn(TotpAuth(authInfo)))
    | None => setAuthStatus(LoggedOut)
    }
  }

  let fetchDetails = async () => {
    open CommonAuthUtils
    open LogicUtils
    try {
      let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")
      let url = getURL(~entityName=USERS, ~userType=#FROM_EMAIL, ~methodType=Post, ())
      switch tokenFromUrl {
      | Some(token) => {
          let response = await updateDetails(url, token->generateBodyForEmailRedirection, Post, ())
          setAuthStatus(
            LoggedIn(TotpAuth(TotpUtils.getTotpAuthInfo(response, ~email_token=Some(token)))),
          )
        }
      | None => setAuthStatus(LoggedOut)
      }
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  React.useEffect0(() => {
    switch url.path {
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStatus(LoggedOut)
    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "accept_invite_from_email"} =>
      fetchDetails()->ignore
    | _ => authLogic()
    }

    None
  })

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut => <TotpAuthScreen setAuthStatus />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <PageLoaderWrapper.ScreenLoader />
    }}
  </div>
}
