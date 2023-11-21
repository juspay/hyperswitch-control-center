open HyperSwitchAuthUtils

module AuthPage = {
  open FramerMotion.Motion
  open HyperSwitchAuth
  @react.component
  let make = (~authType, ~setAuthType, ~setAuthStatus, ~mode, ~setMode) => {
    let {testLiveToggle, magicLink: isMagicLinkEnabled} =
      HyperswitchAtom.featureFlagAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->FeatureFlagUtils.featureFlagType
    let screen =
      <div
        className="h-full flex flex-col items-center justify-between overflow-scoll text-grey-0 w-full mobile:w-30-rem">
        <div className="flex flex-col items-center gap-6 flex-1 mt-4 mobile:my-20">
          <Div layoutId="logo">
            <HyperSwitchLogo logoHeight="h-6" theme={Dark} />
          </Div>
          <UIUtils.RenderIf condition={testLiveToggle}>
            <ToggleLiveTestMode authType mode setMode setAuthType />
          </UIUtils.RenderIf>
          <Div
            layoutId="form"
            className="bg-white text-black mobile:border p-9 rounded-lg flex flex-col justify-between gap-5 mobile:gap-8">
            <HyperSwitchAuth setAuthStatus authType setAuthType />
          </Div>
          <Div
            layoutId="footer-links"
            className="justify-center text-sm mobile:text-base flex flex-col mobile:flex-row mobile:gap-3 items-center w-full max-w-xl text-center">
            {note(authType, setAuthType, isMagicLinkEnabled)}
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
  let {testLiveMode, magicLink: isMagicLinkEnabled} =
    HyperswitchAtom.featureFlagAtom
    ->Recoil.useRecoilValueFromAtom
    ->LogicUtils.safeParse
    ->FeatureFlagUtils.featureFlagType
  let authInitState = isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword
  let (authType, setAuthType) = React.useState(_ => authInitState)

  React.useEffect0(() => {
    switch url.path {
    | list{"user", "verify_email"} => setAuthType(_ => EmailVerify)
    | list{"user", "login"} =>
      setAuthType(_ => isMagicLinkEnabled ? MagicLinkVerify : LoginWithPassword)
    | list{"user", "set_password"} => setAuthType(_ => ResetPassword)
    | list{"register", ..._remainingPath} => setAuthType(_ => SignUP)
    | _ => ()
    }
    None
  })

  React.useEffect1(() => {
    let authInitState = isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword
    setAuthType(_ => authInitState)
    None
  }, [isMagicLinkEnabled])

  React.useEffect1(() => {
    if testLiveMode {
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
