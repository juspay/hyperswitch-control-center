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
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (authMethods, setAuthMethods) = React.useState(_ => AuthUtils.defaultListOfAuth)

  let getAuthDetails = () => {
    open AuthUtils
    open LogicUtils
    let preLoginInfo = getPreLoginDetailsFromLocalStorage()
    let loggedInInfo = getUserInfoDetailsFromLocalStorage()

    if (
      loggedInInfo.token->isNonEmptyString &&
      loggedInInfo.merchant_id->isNonEmptyString &&
      loggedInInfo.email->isNonEmptyString
    ) {
      setAuthStatus(LoggedIn(Auth(loggedInInfo)))
    } else if preLoginInfo.token->isNonEmptyString && preLoginInfo.token_type->isNonEmptyString {
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

  React.useEffect0(() => {
    switch url.path {
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStatus(LoggedOut)
    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "accept_invite_from_email"} =>
      getDetailsFromEmail()->ignore
    | _ => getAuthDetails()
    }

    None
  })

  let getAuthMethods = async () => {
    try {
      open LogicUtils
      // TODO : add query_param for auth_id in the below API
      let authListUrl = getURL(~entityName=USERS, ~userType=#GET_AUTH_LIST, ~methodType=Get, ())
      let listOfAuthMethods = await fetchDetails(authListUrl)
      let arrayFromJson = listOfAuthMethods->getArrayFromJson([])
      if arrayFromJson->Array.length === 0 {
        setAuthMethods(_ => AuthUtils.defaultListOfAuth)
      } else {
        setAuthMethods(_ => arrayFromJson->SSOUtils.getAuthVariants)
      }
    } catch {
    | _ => setAuthMethods(_ => AuthUtils.defaultListOfAuth)
    }
  }

  React.useEffect1(() => {
    // TODO: call this method only when auth_id is present in the URL
    if authStatus === LoggedOut {
      getAuthMethods()->ignore
    }
    None
  }, [authStatus])

  let renderComponentForAuthTypes = (method: SSOTypes.authMethodResponseType) => {
    let authMethodType = method.auth_method.\"type"
    let authMethodName = method.auth_method.name

    switch (authMethodType, authMethodName) {
    | (PASSWORD, #Email_Password) => <TwoFaAuthScreen setAuthStatus />
    | (OPEN_ID_CONNECT, #Okta) | (OPEN_ID_CONNECT, #Google) | (OPEN_ID_CONNECT, #Github) =>
      <Button text={`Login with ${(authMethodName :> string)}`} buttonType={PrimaryOutline} />
    | (_, _) => React.null
    }
  }

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut =>
      <AuthHeaderWrapper childrenStyle="flex flex-col gap-4">
        {authMethods
        ->Array.mapWithIndex((authMethod, index) =>
          <React.Fragment key={index->Int.toString}>
            {authMethod->renderComponentForAuthTypes}
            <UIUtils.RenderIf condition={index === 0 && authMethods->Array.length !== 1}>
              {PreLoginUtils.divider}
            </UIUtils.RenderIf>
          </React.Fragment>
        )
        ->React.array}
      </AuthHeaderWrapper>
    | PreLogin(_) => <DecisionScreen />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <PageLoaderWrapper.ScreenLoader />
    }}
  </div>
}
