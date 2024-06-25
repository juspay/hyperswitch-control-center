module SSOFromEmail = {
  @react.component
  let make = () => {
    open FramerMotion.Motion
    open CommonAuthTypes
    open AuthProviderTypes
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod(~showErrorToast=false, ())
    let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
    let (logoVariant, iconUrl) = switch Window.env.logoUrl {
    | Some(url) => (IconWithURL, Some(url))
    | _ => (IconWithText, None)
    }

    let (authMethods, setAuthMethods) = React.useState(_ => AuthUtils.defaultListOfAuth)

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

    let handleContinueWithHs = async () => {
      try {
        // TODO : add API to get the  next flow
        let preLoginInfo = AuthUtils.getPreLoginDetailsFromLocalStorage()
        setAuthStatus(PreLogin(preLoginInfo))
      } catch {
      | _ => ()
      }
    }

    React.useEffect0(() => {
      getAuthMethods()->ignore
      None
    })

    let renderComponentForAuthTypes = (method: SSOTypes.authMethodResponseType) => {
      let authMethodType = method.auth_method.\"type"
      let authMethodName = method.auth_method.name

      switch (authMethodType, authMethodName) {
      | (PASSWORD, #Email_Password) =>
        <Button
          text="Continue with Hyperswitch"
          buttonType={Primary}
          buttonSize={Large}
          onClick={_ => handleContinueWithHs()->ignore}
        />
      | (OPEN_ID_CONNECT, #Okta) | (OPEN_ID_CONNECT, #Google) | (OPEN_ID_CONNECT, #Github) =>
        <Button
          text={`Login with ${(authMethodName :> string)}`}
          buttonType={PrimaryOutline}
          onClick={_ => handleContinueWithHs()->ignore}
        />
      | (_, _) => React.null
      }
    }

    <HSwitchUtils.BackgroundImageWrapper
      customPageCss="flex flex-col items-center  overflow-scroll ">
      <div
        className="h-full flex flex-col items-center justify-between overflow-scoll text-grey-0 w-full mobile:w-30-rem">
        <div className="flex flex-col items-center gap-6 flex-1 mt-32 w-30-rem">
          <Div layoutId="form" className="bg-white w-full text-black mobile:border rounded-lg">
            <div className="px-7 py-6">
              <Div layoutId="logo">
                <HyperSwitchLogo logoHeight="h-8" theme={Dark} logoVariant iconUrl />
              </Div>
            </div>
            <Div layoutId="border" className="border-b w-full" />
            <div className="flex flex-col gap-4 p-7">
              {authMethods
              ->Array.mapWithIndex((authMethod, index) => <>
                {authMethod->renderComponentForAuthTypes}
                <UIUtils.RenderIf condition={index === 0 && authMethods->Array.length !== 1}>
                  {PreLoginUtils.divider}
                </UIUtils.RenderIf>
              </>)
              ->React.array}
            </div>
          </Div>
        </div>
      </div>
    </HSwitchUtils.BackgroundImageWrapper>
  }
}

module SSOFromRedirect = {
  @react.component
  let make = () => {
    let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

    React.useEffect0(() => {
      // Todo api call to get the next flow
      // SIGN in SSO FLOW
      ()
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
let make = () => {
  open SSOTypes

  let url = RescriptReactRouter.useUrl()
  let path = url.path->List.toArray->Array.joinWith("/")
  let (localSSOState, setLocalSSOState) = React.useState(_ => LOADING)

  React.useEffect1(() => {
    if path->String.includes("redirect_from_sso") {
      setLocalSSOState(_ => SSO_FROM_REDIRECT)
    }
    None
  }, [path])

  switch localSSOState {
  | SSO_FROM_REDIRECT => <SSOFromRedirect />
  | SSO_FROM_EMAIL => <SSOFromEmail />
  | LOADING => <PageLoaderWrapper.ScreenLoader />
  }
}
