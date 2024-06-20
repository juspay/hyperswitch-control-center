let getAuthInfo = json => {
  open LogicUtils
  open AuthProviderTypes
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let totpInfo = {
    email: getString(dict, "email", ""),
    merchant_id: getString(dict, "merchant_id", ""),
    name: getString(dict, "name", ""),
    token: getString(dict, "token", ""),
    role_id: getString(dict, "role_id", ""),
    is_two_factor_auth_setup: getBool(dict, "is_two_factor_auth_setup", false),
    recovery_codes_left: getInt(
      dict,
      "recovery_codes_left",
      HSwitchGlobalVars.maximumRecoveryCodes,
    ),
  }
  totpInfo
}

let getEmailTokenValue = (email_token, dict) => {
  open LogicUtils
  switch email_token {
  | Some(_) => email_token
  | None => dict->getOptionString("email_token")
  }
}

let getPreLoginInfo = (~email_token=None, json) => {
  open LogicUtils
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let preLoginInfo: AuthProviderTypes.preLoginType = {
    token: getString(dict, "token", ""),
    token_type: dict->getString("token_type", ""),
    email_token: getEmailTokenValue(email_token, dict),
  }
  preLoginInfo
}
