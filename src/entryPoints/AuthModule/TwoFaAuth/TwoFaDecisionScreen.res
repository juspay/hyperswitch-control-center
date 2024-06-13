@react.component
let make = () => {
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | PreLogin(info) => info.token_type->TwoFaUtils.flowTypeStrToVariantMapperForNewFlow
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
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
