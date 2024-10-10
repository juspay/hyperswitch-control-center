type commonAuthInfo = {
  token: option<string>,
  merchantId: string,
  name: string,
  email: string,
  userRole: string,
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
  | HE_02
  | UR_00
  | UR_01
  | UR_03
  | UR_05
  | UR_16
  | UR_29
  | UR_33
  | UR_38
  | UR_40
  | UR_41
  | UR_42

type modeType = TestButtonMode | LiveButtonMode
