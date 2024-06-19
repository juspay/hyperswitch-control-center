let storeEmailTokenTmp = emailToken => {
  LocalStorage.setItem("email_token", emailToken)
}

let getAuthInfo = (~email_token=None, json) => {
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
  switch email_token {
  | Some(emailTk) => emailTk->storeEmailTokenTmp
  | None => ()
  }
  totpInfo
}

let getEmailTmpToken = () => {
  LocalStorage.getItem("email_token")->Nullable.toOption
}

let getEmailTokenValue = email_token => {
  let tmpEmailToken = getEmailTmpToken()
  switch email_token {
  | Some(email_token) => {
      email_token->storeEmailTokenTmp
      Some(email_token)
    }
  | None => tmpEmailToken
  }
}

let getPreLoginInfo = (~email_token=None, json) => {
  open LogicUtils
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let preLoginInfo: AuthProviderTypes.preLoginType = {
    token: getString(dict, "token", ""),
    token_type: dict->getString("token_type", ""),
    email_token: email_token->getEmailTokenValue,
  }
  preLoginInfo
}
