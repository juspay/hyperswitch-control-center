open HyperSwitchAuthUtils

module AuthPage = {
  open FramerMotion.Motion
  open HyperSwitchAuth
  @react.component
  let make = (~authType, ~setAuthType, ~setAuthStatus, ~mode, ~setMode) => {
    let {testLiveToggle} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let screen =
      <div
        className="h-full flex flex-col items-center justify-between overflow-scoll text-grey-0 w-full mobile:w-30-rem">
        <div className="flex flex-col items-center gap-6 flex-1 mt-4 mobile:my-20">
          <UIUtils.RenderIf condition={testLiveToggle}>
            <ToggleLiveTestMode authType mode setMode setAuthType />
          </UIUtils.RenderIf>
          <Div layoutId="form" className="bg-white w-full text-black mobile:border rounded-lg">
            <div className="px-7 py-6">
              <Div layoutId="logo">
                <HyperSwitchLogo logoHeight="h-8" theme={Dark} />
              </Div>
            </div>
            <Div layoutId="border" className="border-b w-full" />
            <div className="p-7">
              <HyperSwitchAuth setAuthStatus authType setAuthType />
            </div>
          </Div>
          <Div
            layoutId="footer-links"
            className="justify-center text-sm mobile:text-base flex flex-col mobile:flex-row mobile:gap-3 items-center w-full max-w-xl text-center">
            <TermsAndCondition />
          </Div>
        </div>
        <PageFooterSection />
      </div>

    <HSwitchUtils.BackgroundImageWrapper
      customPageCss="flex flex-col items-center justify-center overflow-scroll">
      {screen}
    </HSwitchUtils.BackgroundImageWrapper>
  }
}

@react.component
let make = (~setAuthStatus: HyperSwitchAuthTypes.authStatus => unit) => {
  open HyperSwitchAuthTypes
  let url = RescriptReactRouter.useUrl()
  let (mode, setMode) = React.useState(_ => TestButtonMode)
  let {isLiveMode, magicLink: isMagicLinkEnabled} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let authInitState = isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword
  let (authType, setAuthType) = React.useState(_ => authInitState)

  React.useEffect1(() => {
    let authInitState = isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword
    setAuthType(_ => authInitState)
    None
  }, [isMagicLinkEnabled])

  React.useEffect1(() => {
    switch url.path {
    | list{"user", "verify_email"} => setAuthType(_ => EmailVerify)
    | list{"user", "login"} =>
      setAuthType(_ => isMagicLinkEnabled ? MagicLinkVerify : LoginWithPassword)
    | list{"user", "set_password"} => setAuthType(_ => ResetPassword)
    | list{"register", ..._remainingPath} => setAuthType(_ => SignUP)
    | _ => ()
    }
    None
  }, [isMagicLinkEnabled])

  React.useEffect1(() => {
    if isLiveMode {
      setMode(_ => LiveButtonMode)
    } else {
      setMode(_ => TestButtonMode)
    }
    None
  }, [url.path])

  React.useEffect1(() => {
    switch (authType, url.path) {
    | (
        LoginWithEmail | LoginWithPassword,
        list{"user", "verify_email"}
        | list{"user", "login"}
        | list{"user", "set_password"}
        | list{"register", ..._},
      ) => () // to prevent duplicate push
    | (LoginWithPassword | LoginWithEmail, _) =>
      `${HSwitchGlobalVars.hyperSwitchFEPrefix}/login`->RescriptReactRouter.replace
    | (SignUP, list{"register", ..._}) => () // to prevent duplicate push
    | (SignUP, _) => "register"->RescriptReactRouter.push
    | (ForgetPassword | ForgetPasswordEmailSent, list{"forget-password", ..._}) => () // to prevent duplicate push
    | (ForgetPassword | ForgetPasswordEmailSent, _) => "forget-password"->RescriptReactRouter.push
    | (ResendVerifyEmail | ResendVerifyEmailSent, list{"resend-mail", ..._}) => () // to prevent duplicate push
    | (ResendVerifyEmail | ResendVerifyEmailSent, _) => "resend-mail"->RescriptReactRouter.push
    | _ => ()
    }
    None
  }, [authType])
  switch authType {
  | EmailVerify | MagicLinkVerify =>
    <HyperSwitchEmailVerifyScreen setAuthType setAuthStatus authType />
  | _ => <AuthPage authType setAuthType setAuthStatus mode setMode />
  }
}
