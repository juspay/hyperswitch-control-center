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
  token: option<string>,
  merchantId: option<string>,
  username: option<string>,
  token_type: totpFlowType,
  email: option<string>,
  userRole: option<string>,
}
type sptTokenType = {
  token: option<string>,
  token_type: totpFlowType,
}
