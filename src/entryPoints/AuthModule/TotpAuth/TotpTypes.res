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
  is_two_factor_auth_setup: option<bool>,
  recovery_codes_left: option<int>,
}

type twoFaPageState = TOTP_SHOW_QR | TOTP_SHOW_RC | TOTP_INPUT_RECOVERY_CODE

type twoFaStatus = TWO_FA_NOT_SET | TWO_FA_SET
