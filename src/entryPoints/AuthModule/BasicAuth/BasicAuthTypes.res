type basicAuthInfo = {
  token: string,
  merchantId: string,
  username: string,
}

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

type modeType = TestButtonMode | LiveButtonMode

type flowType = MERCHANT_SELECT | DASHBOARD_ENTRY | ERROR
