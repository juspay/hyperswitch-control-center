@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) => info.flowType
  | _ => ERROR
  }

  switch (flowType, url.path->HSwitchUtils.urlPath) {
  | (MERCHANT_SELECT, list{"merchant_select"}) | (ACCEPT_INVITE, list{"accept-invite"}) =>
    <AcceptInvite />
  | (TOTP_SETUP, list{"totp_setup"}) => <TOTPSetup />
  | (FORCE_SET_PASSWORD, list{"force_set_password"}) | (RESET_PASSWORD, list{"reset_password"}) =>
    <HSwitchResetPassword />
  | (ACCEPT_INVITATION_FROM_EMAIL, list{"accept_invite_from_email"}) => <HSAcceptInviteFromEmail />
  | (VERIFY_EMAIL, list{"verify_email"}) => <HyperSwitchEmailVerifyScreen />
  | (USER_INFO, list{"user_info"}) => <HSwitchUserInfoScreen />
  | (DASHBOARD_ENTRY, _) => <HyperSwitchApp />
  | (ERROR, _) | (_, _) => <> </>
  }
}
