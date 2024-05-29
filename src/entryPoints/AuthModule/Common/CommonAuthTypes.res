type commonAuthInfo = {
  token: string,
  merchant_id: string,
  name: string,
  email: string,
  user_role: string,
}

type authorization = NoAccess | Access
type logoVariant = Icon | Text | IconWithText | IconWithURL
type authFlow =
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
type data = {code: string, message: string, type_: string}
type subCode =
  | UR_00
  | UR_01
  | UR_03
  | UR_05
  | UR_16
  | UR_29
  | UR_38
  | UR_40
  | UR_41

type modeType = TestButtonMode | LiveButtonMode
