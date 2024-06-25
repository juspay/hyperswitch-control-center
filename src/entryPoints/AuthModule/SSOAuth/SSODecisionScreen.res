module SSOFromRedirect = {
  @react.component
  let make = () => {
    open APIUtils
    let fetchDetails = useGetMethod()
    let getURL = useGetURL()
    let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

    let signInWithSSO = async () => {
      open AuthUtils
      try {
        let ssoUrl = getURL(~entityName=USERS, ~userType=#AUTH_SELECT, ~methodType=Get, ())
        let response = await fetchDetails(ssoUrl)
        setAuthStatus(PreLogin(getPreLoginInfo(response)))
      } catch {
      | _ => setAuthStatus(LoggedOut)
      }
    }

    React.useEffect0(() => {
      signInWithSSO()->ignore
      None
    })

    <HSwitchUtils.BackgroundImageWrapper customPageCss="font-semibold md:text-3xl p-16">
      <div className="h-full w-full flex justify-center items-center text-white opacity-90">
        {"You will be redirecting to the dashboard..."->React.string}
      </div>
    </HSwitchUtils.BackgroundImageWrapper>
  }
}

@react.component
let make = (~auth_id) => {
  open SSOTypes

  let url = RescriptReactRouter.useUrl()
  let path = url.path->List.toArray->Array.joinWith("/")
  let (localSSOState, setLocalSSOState) = React.useState(_ => LOADING)

  Js.log2("sso decision screen", auth_id)

  React.useEffect1(() => {
    if path->String.includes("user/redirect") {
      setLocalSSOState(_ => SSO_FROM_REDIRECT)
    } else {
      Window.Location.replace(`http://localhost:8082/get_url?id=${auth_id}`)
    }
    None
  }, [path])

  switch localSSOState {
  | SSO_FROM_REDIRECT => <SSOFromRedirect />
  | LOADING => <PageLoaderWrapper.ScreenLoader />
  }
}
