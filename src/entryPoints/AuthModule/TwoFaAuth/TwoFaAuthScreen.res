@react.component
let make = (~setAuthStatus) => {
  open CommonAuthTypes
  let url = RescriptReactRouter.useUrl()
  let (_mode, setMode) = React.useState(_ => TestButtonMode)
  let {isMagicLinkEnabled, checkAuthMethodExists} = AuthModuleHooks.useAuthMethods()
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let pageViewEvent = MixpanelHook.usePageView()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let authInitState = LoginWithPassword
  let (authType, setAuthType) = React.useState(_ => authInitState)

  React.useEffect(() => {
    if isLiveMode {
      setMode(_ => LiveButtonMode)
    } else {
      setMode(_ => TestButtonMode)
    }

    switch url.path {
    //redirection url for email
    | list{"user", "verify_email"} => setAuthType(_ => EmailVerify)
    | list{"user", "set_password"} =>
      checkAuthMethodExists([PASSWORD]) ? setAuthType(_ => ResetPassword) : ()
    | list{"user", "accept_invite_from_email"} => setAuthType(_ => ActivateFromEmail)
    | _ =>
      //redirection url for dashboard
      switch url.path->HSwitchUtils.urlPath {
      | list{"login"} => setAuthType(_ => isMagicLinkEnabled() ? LoginWithEmail : LoginWithPassword)
      | list{"forget-password"} =>
        checkAuthMethodExists([PASSWORD]) ? setAuthType(_ => ForgetPassword) : ()
      | list{"register"} => !isLiveMode ? setAuthType(_ => SignUP) : AuthUtils.redirectToLogin()
      | _ => ()
      }
    }
    None
  }, [url.path])

  React.useEffect(() => {
    setAuthType(_ => authType)
    None
  }, [authType])

  React.useEffect(() => {
    let path = url.path->List.toArray->Array.joinWith("/")
    if featureFlagDetails.mixpanel {
      pageViewEvent(~path)->ignore
    }

    None
  }, (featureFlagDetails.mixpanel, authType))

  <TwoFaAuth setAuthStatus authType setAuthType />
}
