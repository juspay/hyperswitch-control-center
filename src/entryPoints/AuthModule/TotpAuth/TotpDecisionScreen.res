@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | ToptAuth(totpInfo) => totpInfo.token_type
    | _ => ERROR
    }
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    setAuthStatus(LoggedOut)
  }

  switch (flowType, url.path->HSwitchUtils.getUrlPath) {
  | (MERCHANT_SELECT, "merchant_select")
  | (ACCEPT_INVITE, "accept_invite") =>
    <TotpMerchantSelectScreen />
  | (TOTP, "totp") => <TotpSetup />
  | (FORCE_SET_PASSWORD, "force_set_password")
  | (RESET_PASSWORD, "set_password") =>
    <TotpResetPassword flowType />
  | (ACCEPT_INVITATION_FROM_EMAIL, "accept_invite_from_email") => <TotpAcceptInviteScreen />
  | (VERIFY_EMAIL, "verify_email") => <TotpEmailVerifyScreen />
  | (USER_INFO, "user_info") => <TotpUserInfoScreen />
  | (DASHBOARD_ENTRY, _) => <HyperSwitchApp />
  | (ERROR, _) | (_, _) => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
