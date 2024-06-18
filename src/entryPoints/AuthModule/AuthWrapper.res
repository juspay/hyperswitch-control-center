module AuthHeaderWrapper = {
  @react.component
  let make = (~children, ~childrenStyle) => {
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
  open AuthProviderTypes
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let fetchApi = AuthHooks.useApiFetcher()
  let updateDetails = useUpdateMethod()
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (authMethods, setAuthMethods) = React.useState(_ => [#Email_Password, #Okta])

  let authLogic = () => {
    open TwoFaUtils
    open LogicUtils
    let preLoginInfo = getTotpPreLoginInfoFromStorage()
    let loggedInInfo = getTotpAuthInfoFromStrorage()

    if (
      loggedInInfo.token->isNonEmptyString &&
      loggedInInfo.merchant_id->isNonEmptyString &&
      loggedInInfo.email->isNonEmptyString
    ) {
      setAuthStatus(LoggedIn(Auth(loggedInInfo)))
    } else if (
      preLoginInfo.token->isNonEmptyString &&
      preLoginInfo.token_type->isNonEmptyString &&
      preLoginInfo.token_type == "sso"
    ) {
      setAuthStatus(SSOPreLogin(preLoginInfo))
    } else if preLoginInfo.token->isNonEmptyString && preLoginInfo.token_type->isNonEmptyString {
      setAuthStatus(PreLogin(preLoginInfo))
    } else {
      setAuthStatus(LoggedOut)
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

          // TODO: rethink this condition
          let tokenType = "sso"
          // response->getDictFromJsonObject->getString("token_type", "sso")
          switch tokenType {
          | "sso" =>
            setAuthStatus(
              SSOPreLogin(TwoFaUtils.getPreLoginInfo(response, ~email_token=Some(token))),
            )
          | _ =>
            setAuthStatus(PreLogin(TwoFaUtils.getPreLoginInfo(response, ~email_token=Some(token))))
          }
        }
      | None => setAuthStatus(LoggedOut)
      }
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  let handlePreLogin = () => {
    Js.log("inside handle redirect")
    //api
    // code url
    // backend
    // details from okta
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
    | list{"user", "redirect_from_sso"} => handlePreLogin()
    | _ => authLogic()
    }
    None
  })

  let getAuthMethods = async () => {
    try {
      // TODO : api to get the auth methods
      // let url = getURL(~entityName=USERS, ~userType=#FROM_EMAIL, ~methodType=Post, ())
      // setAuthMethods(_=>[])
      ()
    } catch {
    | _ => ()
    }
  }

  let handleLoginWithSso = async () => {
    open Promise
    // let url = "http:://localhost:8082/generate"
    // let res = await fetchApi(url, ~method_=Get, ())

    Fetch.fetchWithInit(
      `http://localhost:8082/generate`,
      Fetch.RequestInit.make(~method_=Fetch.Get, ()),
    )
    ->then(res => res->Fetch.Response.json)
    ->thenResolve(json => {
      Js.log("came isnide here")
    })
    ->catch(_err => {
      resolve()
    })
    ->ignore
  }

  React.useEffect1(() => {
    if authStatus === LoggedOut {
      getAuthMethods()->ignore
    }
    None
  }, [authStatus])

  let renderComponentForAuthTypes = (method: AuthProviderTypes.authMethodTypes) =>
    switch method {
    | #Email_Password => <TwoFaAuthScreen setAuthStatus />
    | #Okta | #Google | #Github =>
      <Button
        text={`Login with ${(method :> string)}`}
        buttonType={PrimaryOutline}
        onClick={_ => handleLoginWithSso()->ignore}
      />
    }

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut =>
      <AuthHeaderWrapper childrenStyle="flex flex-col gap-4">
        {authMethods
        ->Array.mapWithIndex((authMethod, index) => <>
          {authMethod->renderComponentForAuthTypes}
          <UIUtils.RenderIf condition={index === 0 && authMethods->Array.length !== 1}>
            {AuthUtils.divider}
          </UIUtils.RenderIf>
        </>)
        ->React.array}
      </AuthHeaderWrapper>
    | SSOPreLogin(_) => <SSODecisionScreen />
    | PreLogin(_) => <TwoFaDecisionScreen />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <PageLoaderWrapper.ScreenLoader />
    }}
  </div>
}
