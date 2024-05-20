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
  merchant_id: option<string>,
  name: option<string>,
  token_type: option<string>,
  email: option<string>,
  role_id: option<string>,
  email_token: option<string>,
}
