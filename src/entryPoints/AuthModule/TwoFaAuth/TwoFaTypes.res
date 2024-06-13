type twoFaFlowType =
  | MERCHANT_SELECT
  | TOTP
  | FORCE_SET_PASSWORD
  | ACCEPT_INVITE
  | VERIFY_EMAIL
  | ACCEPT_INVITATION_FROM_EMAIL
  | RESET_PASSWORD
  | USER_INFO
  | ERROR

type twoFaAuthInfo = {
  token: string,
  merchant_id: string,
  name: string,
  email: string,
  role_id: string,
  is_two_factor_auth_setup: bool,
  recovery_codes_left: int,
}

type twoFaPageState = TOTP_SHOW_QR | TOTP_SHOW_RC | TOTP_INPUT_RECOVERY_CODE

type twoFaStatus = TWO_FA_NOT_SET | TWO_FA_SET
