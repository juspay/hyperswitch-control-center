@react.component
let make = () => {
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | TotpAuth(totpInfo) => totpInfo.token_type->TotpUtils.flowTypeStrToVariantMapper
    | _ => ERROR
    }
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    setAuthStatus(LoggedOut)
  }

  switch flowType {
  | MERCHANT_SELECT
  | ACCEPT_INVITE =>
    <TotpMerchantSelectScreen />
  | TOTP => <TotpSetup />
  | FORCE_SET_PASSWORD
  | RESET_PASSWORD =>
    <TotpResetPassword flowType />
  | ACCEPT_INVITATION_FROM_EMAIL => <TotpAcceptInviteScreen />
  | VERIFY_EMAIL => <TotpEmailVerifyScreen />
  | USER_INFO => <TotpUserInfoScreen />
  | DASHBOARD_ENTRY => <HyperSwitchApp />
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
