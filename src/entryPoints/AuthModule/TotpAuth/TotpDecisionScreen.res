@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | ToptAuth(totpInfo) => totpInfo.token_type
    | _ => ERROR
    }
  | _ => ERROR
  }

  switch (flowType, url.path->HSwitchUtils.urlPath) {
  | (MERCHANT_SELECT, list{"merchant_select"}) | (ACCEPT_INVITE, list{"accept_invite"}) =>
    <TotpMerchantSelectScreen />
  | (TOTP, list{"totp"}) => <TotpSetup />
  | (FORCE_SET_PASSWORD, list{"force_set_password"}) | (RESET_PASSWORD, list{"reset_password"}) =>
    <TotpResetPassword flowType />
  | (ACCEPT_INVITATION_FROM_EMAIL, list{"accept_invite_from_email"}) => <TotpAcceptInviteScreen />
  | (VERIFY_EMAIL, list{"verify_email"}) => <TotpEmailVerifyScreen />
  | (USER_INFO, list{"user_info"}) => <TotpUserInfoScreen />
  | (DASHBOARD_ENTRY, _) => <HyperSwitchApp />
  | (ERROR, _) | (_, _) => <> </>
  }
}
