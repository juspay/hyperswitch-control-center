@react.component
let make = () => {
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | PreLogin(info) => info.token_type->PreLoginUtils.flowTypeStrToVariantMapperForNewFlow
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    setAuthStatus(LoggedOut)
  }

  switch flowType {
  | SSO => <SSODecisionScreen />
  | MERCHANT_SELECT
  | ACCEPT_INVITE =>
    <MerchantSelectScreen />
  | TOTP => <TotpSetup />
  | FORCE_SET_PASSWORD
  | RESET_PASSWORD =>
    <ResetPassword flowType />
  | ACCEPT_INVITATION_FROM_EMAIL => <AcceptInviteScreen />
  | VERIFY_EMAIL => <VerifyUserFromEmail onClick=onClickErrorPageButton />
  | USER_INFO => <UserInfoScreen />
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
