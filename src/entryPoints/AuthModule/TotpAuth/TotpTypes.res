type totpFlowType =
  | MERCHANT_SELECT
  | DASHBOARD_ENTRY
  | TOTP
  | FORCE_SET_PASSWORD
  | ACCEPT_INVITE
  | VERIFY_EMAIL
  | ACCEPT_INVITATION_FROM_EMAIL
  | RESET_PASSWORD
  | USER_INFO
  | ERROR

type totpAuthInfo = {
  token: string,
  merchantId: string,
  username: string,
  token_type: totpFlowType,
}
type sptTokenType = {
  token: option<string>,
  token_type: totpFlowType,
}
