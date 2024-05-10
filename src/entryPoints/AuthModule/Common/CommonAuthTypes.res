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
