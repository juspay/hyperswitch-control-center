@react.component
let make = (~setAuthStatus) => {
  open CommonAuthTypes
  let url = RescriptReactRouter.useUrl()
  let (_mode, setMode) = React.useState(_ => TestButtonMode)
  let {isMagicLinkEnabled} = AuthModuleHooks.useAuthMethods()
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let authInitState = isMagicLinkEnabled() ? LoginWithEmail : LoginWithPassword
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
      setActualAuthType(_ => isMagicLinkEnabled() ? LoginWithEmail : LoginWithPassword)
    | list{"user", "set_password"} => setActualAuthType(_ => ResetPassword)
    | list{"user", "accept_invite_from_email"} => setActualAuthType(_ => ActivateFromEmail)
    | list{"forget-password"} => setActualAuthType(_ => ForgetPassword)
    | list{"register"} =>
      // In Live mode users are not allowed to singup directly
      !isLiveMode ? setActualAuthType(_ => SignUP) : AuthUtils.redirectToLogin()
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
    | (LoginWithPassword | LoginWithEmail, _) => AuthUtils.redirectToLogin()

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

  <TwoFaAuth setAuthStatus authType setAuthType />
}
