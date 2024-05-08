open BasicAuthUtils

module BasicAuthPage = {
  open FramerMotion.Motion
  open CommonAuthTypes
  @react.component
  let make = (~authType, ~setAuthType, ~setAuthStatus, ~mode, ~setMode) => {
    let {testLiveToggle, branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let (logoVariant, iconUrl) = switch (Window.env.logoUrl, branding) {
    | (Some(url), true) => (IconWithURL, Some(url))
    | (Some(url), false) => (IconWithURL, Some(url))
    | _ => (IconWithText, None)
    }
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
                <HyperSwitchLogo logoHeight="h-8" theme={Dark} logoVariant iconUrl />
              </Div>
            </div>
            <Div layoutId="border" className="border-b w-full" />
            <div className="p-7">
              <BasicAuth setAuthStatus authType setAuthType />
            </div>
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

    <HSwitchUtils.BackgroundImageWrapper
      customPageCss="flex flex-col items-center justify-center overflow-scroll">
      {screen}
    </HSwitchUtils.BackgroundImageWrapper>
  }
}

@react.component
let make = (~setAuthStatus) => {
  open BasicAuthTypes
  open CommonAuthTypes
  let url = RescriptReactRouter.useUrl()
  let (mode, setMode) = React.useState(_ => TestButtonMode)
  let {isLiveMode, email: isMagicLinkEnabled} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let authInitState = isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword
  let (authType, setAuthType) = React.useState(_ => authInitState)

  let (actualAuthType, setActualAuthType) = React.useState(_ => authInitState)

  React.useEffect1(() => {
    if isLiveMode {
      setMode(_ => LiveButtonMode)
    } else {
      setMode(_ => TestButtonMode)
    }

    switch url.path {
    | list{"user", "verify_email"} => setActualAuthType(_ => EmailVerify)
    | list{"login"} =>
      setActualAuthType(_ => isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword)
    | list{"user", "set_password"} => setActualAuthType(_ => ResetPassword)
    | list{"user", "accept_invite_from_email"} => setActualAuthType(_ => ActivateFromEmail)
    | list{"forget-password"} => setActualAuthType(_ => ForgetPassword)
    | list{"register"} =>
      // In Live mode users are not allowed to singup directly
      !isLiveMode
        ? setActualAuthType(_ => SignUP)
        : HSwitchGlobalVars.appendDashboardPath(~url="/login")->RescriptReactRouter.push
    | _ => ()
    }

    None
  }, [url.path])

  React.useEffect1(() => {
    if authType != actualAuthType {
      setAuthType(_ => actualAuthType)
    }
    None
  }, [actualAuthType])

  React.useEffect1(() => {
    switch (authType, url.path) {
    | (
        LoginWithEmail | LoginWithPassword,
        list{"user", "verify_email"}
        | list{"user", "accept_invite_from_email"}
        | list{"user", "login"}
        | list{"user", "set_password"}
        | list{"register", ..._},
      ) => () // to prevent duplicate push
    | (LoginWithPassword | LoginWithEmail, _) =>
      HSwitchGlobalVars.appendDashboardPath(~url="/login")->RescriptReactRouter.replace

    | (SignUP, list{"register", ..._}) => () // to prevent duplicate push
    | (SignUP, _) =>
      HSwitchGlobalVars.appendDashboardPath(~url="/register")->RescriptReactRouter.push

    | (ForgetPassword | ForgetPasswordEmailSent, list{"forget-password", ..._}) => () // to prevent duplicate push
    | (ForgetPassword | ForgetPasswordEmailSent, _) =>
      HSwitchGlobalVars.appendDashboardPath(~url="/forget-password")->RescriptReactRouter.push

    | (ResendVerifyEmail | ResendVerifyEmailSent, list{"resend-mail", ..._}) => () // to prevent duplicate push
    | (ResendVerifyEmail | ResendVerifyEmailSent, _) =>
      HSwitchGlobalVars.appendDashboardPath(~url="/resend-mail")->RescriptReactRouter.push

    | _ => ()
    }
    None
  }, [authType])
  switch authType {
  | EmailVerify | MagicLinkVerify => <BasicEmailVerifyScreen setAuthType setAuthStatus />
  | ActivateFromEmail => <BasicInviteFromEmail setAuthType setAuthStatus />
  | _ => <BasicAuthPage authType setAuthType setAuthStatus mode setMode />
  }
}
