type authInfo = {
  email: string,
  name: string,
  token: string,
  merchantId: string,
  username: string,
}

type authStatus = LoggedOut | LoggedIn(authInfo) | CheckingAuthStatus
open LogicUtils

let getAuthInfo = (json, str) => {
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let emailKey = "email"

  let tokenKey = "token"

  let name = "name"
  let merchantIdKey = "merchantId"
  let userNameKey = "username"

  let authInfo = {
    name: getString(dict, name, ""),
    email: getString(dict, emailKey, ""),
    token: getString(dict, tokenKey, str),
    merchantId: getString(dict, merchantIdKey, str),
    username: getString(dict, userNameKey, ""),
  }

  Some(authInfo)
}

let getDummyAuthInfoForToken = token => {
  let authInfo = {
    name: "",
    email: "",
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
