let flowTypeStrToVariantMapper = val => {
  open HyperSwitchAuthTypes
  switch val {
  // old types
  | Some("merchant_select") => MERCHANT_SELECT
  | Some("dashboard_entry") => DASHBOARD_ENTRY

  | Some("totp") => TOTP_SETUP

  // rotate password
  | Some("force_set_password") => FORCE_SET_PASSWORD

  // merchant select
  | Some("accept_invite") => ACCEPT_INVITE

  | Some("accept_invitation_from_email") => ACCEPT_INVITATION_FROM_EMAIL
  | Some("verify_email") => VERIFY_EMAIL
  | Some("reset_password") => RESET_PASSWORD

  // home call
  | Some("user_info") => USER_INFO
  | Some(_) => ERROR
  | None => ERROR
  }
}

let variantToStringFlowMapper = val => {
  open HyperSwitchAuthTypes
  switch val {
  | DASHBOARD_ENTRY => "dashboard_entry"
  | MERCHANT_SELECT => "merchant_select"
  | TOTP_SETUP => "totp"
  | FORCE_SET_PASSWORD => "force_set_password"
  | ACCEPT_INVITE => "accept_invite"
  | VERIFY_EMAIL => "verify_email"
  | ACCEPT_INVITATION_FROM_EMAIL => "accept_invitation_from_email"
  | RESET_PASSWORD => "reset_password"
  | USER_INFO => "user_info"
  | ERROR => ""
  }
}

let getAuthInfo = (json, str) => {
  open HyperSwitchAuthTypes
  open LogicUtils

  let dict = json->JsonFlattenUtils.flattenObject(false)
  let tokenKey = "token"
  let merchantIdKey = "merchantId"
  let userNameKey = "username"
  let token_type = "token_type"

  let authInfo = {
    token: getString(dict, tokenKey, str),
    merchantId: getString(dict, merchantIdKey, str),
    username: getString(dict, userNameKey, ""),
    flowType: getOptionString(dict, token_type)->flowTypeStrToVariantMapper,
  }

  Some(authInfo)
}

let getDummyAuthInfoForToken = (token, flowType) => {
  open HyperSwitchAuthTypes
  let authInfo = {
    token,
    merchantId: "",
    username: "",
    flowType,
  }

  authInfo
}

let sptToken = (token, tokenType) => {
  LocalStorage.setItem("login", token)
  LocalStorage.setItem("token_type", tokenType)
}

let getSptTokenType: unit => HyperSwitchAuthTypes.sptTokenType = () => {
  let token = LocalStorage.getItem("login")->Nullable.toOption
  let tokenType = LocalStorage.getItem("token_type")->Nullable.toOption->flowTypeStrToVariantMapper

  {
    token,
    token_type: tokenType,
  }
}

let clearLocalStorage = () => {
  LocalStorage.clear()
}
