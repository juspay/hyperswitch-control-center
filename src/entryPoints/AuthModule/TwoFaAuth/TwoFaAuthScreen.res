@react.component
let make = (~setAuthStatus) => {
  open CommonAuthTypes
  let url = RescriptReactRouter.useUrl()
  let (_mode, setMode) = React.useState(_ => TestButtonMode)
  let {isMagicLinkEnabled, checkAuthMethodExists} = AuthModuleHooks.useAuthMethods()
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let authInitState = LoginWithPassword
  let (authType, setAuthType) = React.useState(_ => authInitState)

  let (actualAuthType, setActualAuthType) = React.useState(_ => authInitState)

  React.useEffect(() => {
    if isLiveMode {
      setMode(_ => LiveButtonMode)
    } else {
      setMode(_ => TestButtonMode)
    }

    switch url.path {
    | list{"user", "verify_email"} => setActualAuthType(_ => EmailVerify)
    | list{"login"} =>
      setActualAuthType(_ => isMagicLinkEnabled() ? LoginWithEmail : LoginWithPassword)
    | list{"user", "set_password"} =>
      checkAuthMethodExists([PASSWORD]) ? setActualAuthType(_ => ResetPassword) : ()
    | list{"user", "accept_invite_from_email"} => setActualAuthType(_ => ActivateFromEmail)
    | list{"forget-password"} =>
      checkAuthMethodExists([PASSWORD]) ? setActualAuthType(_ => ForgetPassword) : ()
    | list{"register"} =>
      // In Live mode users are not allowed to singup directly
      !isLiveMode ? setActualAuthType(_ => SignUP) : AuthUtils.redirectToLogin()
    | _ => ()
    }

    None
  }, [url.path])

  React.useEffect(() => {
    if authType != actualAuthType {
      setAuthType(_ => actualAuthType)
    }
    None
  }, [actualAuthType])

  React.useEffect(() => {
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
    | (SignUP, _) => GlobalVars.appendDashboardPath(~url="/register")->RescriptReactRouter.push

    | (ForgetPassword | ForgetPasswordEmailSent, list{"forget-password", ..._}) => () // to prevent duplicate push
    | (ForgetPassword | ForgetPasswordEmailSent, _) =>
      GlobalVars.appendDashboardPath(~url="/forget-password")->RescriptReactRouter.push

    | (ResendVerifyEmail | ResendVerifyEmailSent, list{"resend-mail", ..._}) => () // to prevent duplicate push
    | (ResendVerifyEmail | ResendVerifyEmailSent, _) =>
      GlobalVars.appendDashboardPath(~url="/resend-mail")->RescriptReactRouter.push

    | _ => ()
    }
    None
  }, [authType])

  <TwoFaAuth setAuthStatus authType setAuthType />
}
