module SSOFromRedirect = {
  @react.component
  let make = (~localSSOState) => {
    open SSOTypes
    open APIUtils
    let updateDetails = useUpdateMethod()
    let getURL = useGetURL()

    let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

    let signInWithSSO = async () => {
      open AuthUtils
      try {
        let body = switch localSSOState {
        | SSO_FROM_REDIRECT(#Okta(data)) => data->Identity.genericTypeToJson
        | _ => Dict.make()->JSON.Encode.object
        }
        let ssoUrl = getURL(~entityName=USERS, ~userType=#SIGN_IN_WITH_SSO, ~methodType=Post, ())
        let response = await updateDetails(ssoUrl, body, Post, ())
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
let make = (~auth_id: option<string>) => {
  open SSOTypes
  let url = RescriptReactRouter.useUrl()
  let path = url.path->List.toArray->Array.joinWith("/")
  let (localSSOState, setLocalSSOState) = React.useState(_ => LOADING)

  let oktaMethod = () => {
    open LogicUtils
    let dict = url.search->getDictFromUrlSearchParams
    let okta = {
      code: dict->Dict.get("code"),
      state: dict->Dict.get("state"),
    }
    setLocalSSOState(_ => SSO_FROM_REDIRECT(#Okta(okta)))
  }

  React.useEffect1(() => {
    switch (url.path, auth_id) {
    | (list{"redirect", "oidc", "okta"}, _) => oktaMethod()
    | (_, Some(str)) => Window.Location.replace(`${Window.env.apiBaseUrl}/user/auth/url?id=${str}`)
    | _ => ()
    }
    None
  }, [path])

  switch localSSOState {
  | SSO_FROM_REDIRECT(_) => <SSOFromRedirect localSSOState />
  | LOADING => <PageLoaderWrapper.ScreenLoader />
  }
}
