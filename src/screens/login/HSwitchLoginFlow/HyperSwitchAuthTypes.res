type flowType =
  | MERCHANT_SELECT
  | DASHBOARD_ENTRY
  | TOTP_SETUP
  | FORCE_SET_PASSWORD
  | ACCEPT_INVITE
  | VERIFY_EMAIL
  | ACCEPT_INVITATION_FROM_EMAIL
  | RESET_PASSWORD
  | USER_INFO
  | ERROR

type authInfo = {
  token: string,
  merchantId: string,
  username: string,
  flowType: flowType,
}

type authStatus = LoggedOut | LoggedIn(authInfo) | CheckingAuthStatus

type authType =
  | LoginWithPassword
  | LoginWithEmail
  | SignUP
  | EmailVerify
  | MagicLinkVerify
  | ForgetPassword
  | ForgetPasswordEmailSent
  | ResendVerifyEmailSent
  | MagicLinkEmailSent
  | ResetPassword
  | ResendVerifyEmail
  | LiveMode
  | ActivateFromEmail

type modeType = TestButtonMode | LiveButtonMode

type data = {code: string, message: string, type_: string}

type subCode =
  | UR_00
  | UR_01
  | UR_03
  | UR_05
  | UR_16

type logoVariant = Icon | Text | IconWithText | IconWithURL

type defaultProviderTypes = {
  authStatus: authStatus,
  setAuthStatus: authStatus => unit,
}
type sptTokenType = {
  token: option<string>,
  token_type: flowType,
}
