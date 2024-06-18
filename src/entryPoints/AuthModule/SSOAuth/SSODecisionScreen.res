module SSOLanding = {
  @react.component
  let make = () => {
    open FramerMotion.Motion
    open CommonAuthTypes
    open AuthProviderTypes

    let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
    let (logoVariant, iconUrl) = switch Window.env.logoUrl {
    | Some(url) => (IconWithURL, Some(url))
    | _ => (IconWithText, None)
    }

    let (authMethods, setAuthMethods) = React.useState(_ => [#Email_Password])

    let getAuthMethods = async () => {
      try {
        // TODO : add get auth details API
        // setAuthMethods(_ => [#Email_Password, #Okta])
        ()
      } catch {
      | _ => ()
      }
    }

    let handleContinueWithHs = async () => {
      try {
        // TODO : add API to get the  next flow
        let preLoginInfo = TwoFaUtils.getTotpPreLoginInfoFromStorage()
        setAuthStatus(PreLogin(preLoginInfo))
      } catch {
      | _ => ()
      }
    }

    React.useEffect0(() => {
      getAuthMethods()->ignore
      None
    })

    let renderComponentForAuthTypes = (method: AuthProviderTypes.authMethodTypes) =>
      switch method {
      | #Email_Password =>
        <Button
          text="Continue with Hyperswitch"
          buttonType={Primary}
          buttonSize={Large}
          onClick={_ => handleContinueWithHs()->ignore}
        />
      | #Okta | #Google | #Github =>
        <Button text={`Login with ${(method :> string)}`} buttonType={PrimaryOutline} />
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
                  {AuthUtils.divider}
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

@react.component
let make = () => {
  open SsoTypes
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | SSOPreLogin(info) => info.token_type->SsoUtils.flowTypeStrToVariantMapper
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    setAuthStatus(LoggedOut)
  }

  switch flowType {
  | SSO_FROM_EMAIL => <SSOLanding />
  | USER_INFO => <UserInfoScreen />
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
