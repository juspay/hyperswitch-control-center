module AuthHeaderWrapper = {
  @react.component
  let make = (~children, ~childrenStyle="") => {
    open FramerMotion.Motion
    open CommonAuthTypes

    let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let (logoVariant, iconUrl) = switch (Window.env.logoUrl, branding) {
    | (Some(url), true) => (IconWithURL, Some(url))
    | (Some(url), false) => (IconWithURL, Some(url))
    | _ => (IconWithText, None)
    }

    <HSwitchUtils.BackgroundImageWrapper
      customPageCss="flex flex-col items-center justify-center overflow-scroll">
      <div
        className="h-full flex flex-col items-center justify-between overflow-scoll text-grey-0 w-full mobile:w-30-rem">
        <div className="flex flex-col items-center gap-6 flex-1 mt-4 mobile:my-20">
          <Div layoutId="form" className="bg-white w-full text-black mobile:border rounded-lg">
            <div className="px-7 py-6">
              <Div layoutId="logo">
                <HyperSwitchLogo logoHeight="h-8" theme={Dark} logoVariant iconUrl />
              </Div>
            </div>
            <Div layoutId="border" className="border-b w-full" />
            <div className={`p-7 ${childrenStyle}`}> {children} </div>
          </Div>
          <UIUtils.RenderIf condition={!branding}>
            <Div
              layoutId="footer-links"
              className="justify-center text-sm mobile:text-base flex flex-col mobile:flex-row mobile:gap-3 items-center w-full max-w-xl text-center">
              <CommonAuth.TermsAndCondition />
            </Div>
          </UIUtils.RenderIf>
        </div>
        <UIUtils.RenderIf condition={!branding}>
          <CommonAuth.PageFooterSection />
        </UIUtils.RenderIf>
      </div>
    </HSwitchUtils.BackgroundImageWrapper>
  }
}

@react.component
let make = (~children) => {
  open APIUtils

  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let {fetchAuthMethods, checkAuthMethodExists} = AuthModuleHooks.useAuthMethods()
  let {authStatus, setAuthStatus, authMethods} = React.useContext(
    AuthInfoProvider.authStatusContext,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let getAuthDetails = () => {
    open AuthUtils
    open LogicUtils
    let preLoginInfo = getPreLoginDetailsFromLocalStorage()
    let loggedInInfo = getUserInfoDetailsFromLocalStorage()

    if (
      loggedInInfo.token->Option.isSome &&
      loggedInInfo.merchant_id->isNonEmptyString &&
      loggedInInfo.email->isNonEmptyString
    ) {
      setAuthStatus(LoggedIn(Auth(loggedInInfo)))
    } else if preLoginInfo.token->Option.isSome && preLoginInfo.token_type->isNonEmptyString {
      setAuthStatus(PreLogin(preLoginInfo))
    } else {
      setAuthStatus(LoggedOut)
    }
  }

  let getDetailsFromEmail = async () => {
    open CommonAuthUtils
    open LogicUtils
    try {
      let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")
      let url = getURL(~entityName=USERS, ~userType=#FROM_EMAIL, ~methodType=Post, ())
      switch tokenFromUrl {
      | Some(token) => {
          let response = await updateDetails(url, token->generateBodyForEmailRedirection, Post, ())
          setAuthStatus(PreLogin(AuthUtils.getPreLoginInfo(response, ~email_token=Some(token))))
        }
      | None => setAuthStatus(LoggedOut)
      }
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  let handleRedirectFromSSO = () => {
    open AuthUtils
    let info = getPreLoginDetailsFromLocalStorage()->SSOUtils.ssoDefaultValue
    setAuthStatus(PreLogin(info))
  }

  let handleLoginWithSso = auth_id => {
    Window.Location.replace(`${Window.env.apiBaseUrl}/user/auth/url?id=${auth_id}`)
  }

  React.useEffect0(() => {
    switch url.path {
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStatus(LoggedOut)
    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "accept_invite_from_email"} =>
      getDetailsFromEmail()->ignore
    | list{"redirect", "oidc", ..._} => handleRedirectFromSSO()
    | _ => getAuthDetails()
    }

    None
  })

  let getAuthMethods = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await fetchAuthMethods()
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Success)
    }
  }

  React.useEffect1(() => {
    if authStatus === LoggedOut {
      getAuthMethods()->ignore
    }
    None
  }, [authStatus])

  let renderComponentForAuthTypes = (method: SSOTypes.authMethodResponseType) => {
    let authMethodType = method.auth_method.\"type"
    let authMethodName = method.auth_method.name
    switch (authMethodType, authMethodName) {
    | (OPEN_ID_CONNECT, #Okta) | (OPEN_ID_CONNECT, #Google) | (OPEN_ID_CONNECT, #Github) =>
      <Button
        text={`Continue with ${(authMethodName :> string)}`}
        buttonType={PrimaryOutline}
        onClick={_ => handleLoginWithSso(method.id)}
      />
    | (_, _) => React.null
    }
  }

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut =>
      <PageLoaderWrapper screenState>
        <AuthHeaderWrapper childrenStyle="flex flex-col gap-4">
          <UIUtils.RenderIf condition={checkAuthMethodExists([PASSWORD, MAGIC_LINK])}>
            <TwoFaAuthScreen setAuthStatus />
          </UIUtils.RenderIf>
          <UIUtils.RenderIf condition={checkAuthMethodExists([OPEN_ID_CONNECT])}>
            {PreLoginUtils.divider}
            {authMethods
            ->Array.mapWithIndex((authMethod, index) =>
              <React.Fragment key={index->Int.toString}>
                {authMethod->renderComponentForAuthTypes}
              </React.Fragment>
            )
            ->React.array}
          </UIUtils.RenderIf>
        </AuthHeaderWrapper>
      </PageLoaderWrapper>
    | PreLogin(_) => <DecisionScreen />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <PageLoaderWrapper.ScreenLoader />
    }}
  </div>
}
