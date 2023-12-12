type authInfo = {
  token: string,
  merchantId: string,
  username: string,
}

type authStatus = LoggedOut | LoggedIn(authInfo) | CheckingAuthStatus
open LogicUtils

let getAuthInfo = (json, str) => {
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let tokenKey = "token"
  let merchantIdKey = "merchantId"
  let userNameKey = "username"

  let authInfo = {
    token: getString(dict, tokenKey, str),
    merchantId: getString(dict, merchantIdKey, str),
    username: getString(dict, userNameKey, ""),
  }

  Some(authInfo)
}

let getDummyAuthInfoForToken = token => {
  let authInfo = {
    token,
    merchantId: "",
    username: "",
  }

  authInfo
}

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

type modeType = TestButtonMode | LiveButtonMode

type data = {code: string, message: string, type_: string}

type subCode =
  | UR_00
  | UR_01
  | UR_03
  | UR_05
  | UR_16
