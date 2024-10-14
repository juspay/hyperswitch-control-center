@react.component
let make = () => {
  let (selectedAuthId, setSelectedAuthId) = React.useState(_ => None)
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | PreLogin(info) => info.token_type->PreLoginUtils.flowTypeStrToVariantMapperForNewFlow
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    setAuthStatus(LoggedOut)
  }

  switch flowType {
  | AUTH_SELECT => <AuthSelect setSelectedAuthId />
  | SSO => <SSODecisionScreen auth_id=selectedAuthId />
  | MERCHANT_SELECT
  | ACCEPT_INVITE =>
    <ListInvitationScreen />
  | TOTP => <TwoFaLanding />
  | FORCE_SET_PASSWORD
  | RESET_PASSWORD =>
    <ResetPassword flowType />
  | ACCEPT_INVITATION_FROM_EMAIL => <AcceptInviteScreen onClick=onClickErrorPageButton />
  | VERIFY_EMAIL => <VerifyUserFromEmail onClick=onClickErrorPageButton />
  | USER_INFO => <UserInfoScreen onClick=onClickErrorPageButton />
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
