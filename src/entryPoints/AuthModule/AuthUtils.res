let getAuthInfo = json => {
  open LogicUtils
  open AuthProviderTypes
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let totpInfo = {
    email: getString(dict, "email", ""),
    merchant_id: getString(dict, "merchant_id", ""),
    name: getString(dict, "name", ""),
    token: getString(dict, "token", "")->getNonEmptyString,
    role_id: getString(dict, "role_id", ""),
    is_two_factor_auth_setup: getBool(dict, "is_two_factor_auth_setup", false),
    recovery_codes_left: getInt(dict, "recovery_codes_left", GlobalVars.maximumRecoveryCodes),
  }
  totpInfo
}
let storeEmailTokenTmp = emailToken => {
  LocalStorage.setItem("email_token", emailToken)
}

let getEmailTmpToken = () => {
  LocalStorage.getItem("email_token")->Nullable.toOption
}

let getEmailTokenValue = email_token => {
  switch email_token {
  | Some(str) => {
      str->storeEmailTokenTmp
      email_token
    }
  | None => getEmailTmpToken()
  }
}

let getPreLoginInfo = (~email_token=None, json) => {
  open LogicUtils
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let preLoginInfo: AuthProviderTypes.preLoginType = {
    token: dict->getString("token", "")->getNonEmptyString,
    token_type: dict->getString("token_type", ""),
    email_token: getEmailTokenValue(email_token),
  }
  preLoginInfo
}

let setDetailsToLocalStorage = (json, key) => {
  LocalStorage.setItem(key, json->JSON.stringifyAny->Option.getOr(""))
}

let getPreLoginDetailsFromLocalStorage = () => {
  open LogicUtils
  let json = LocalStorage.getItem("PRE_LOGIN_INFO")->getValFromNullableValue("")->safeParse
  json->getPreLoginInfo
}

let getUserInfoDetailsFromLocalStorage = () => {
  open LogicUtils
  let json = LocalStorage.getItem("USER_INFO")->getValFromNullableValue("")->safeParse
  json->getAuthInfo
}

let defaultListOfAuth: array<SSOTypes.authMethodResponseType> = [
  {
    id: None,
    auth_id: "defaultpasswordAuthId",
    auth_method: {
      \"type": PASSWORD,
      name: #Password,
    },
    allow_signup: true,
  },
  {
    id: None,
    auth_id: "defaultmagicLinkId",
    auth_method: {
      \"type": MAGIC_LINK,
      name: #Magic_Link,
    },
    allow_signup: true,
  },
]

let redirectToLogin = () => {
  open HyperSwitchEntryUtils
  open GlobalVars
  open LogicUtils

  let authId = getSessionData(~key="auth_id", ())
  let domain = getSessionData(~key="domain", ())

  let urlToRedirect = switch (authId->isNonEmptyString, domain->isNonEmptyString) {
  | (true, true) => `/login?auth_id=${authId}&domain=${domain}`
  | (true, false) => `/login?auth_id=${authId}`
  | (false, true) => `/login?domain=${domain}`
  | (_, _) => `/login`
  }
  RescriptReactRouter.push(appendDashboardPath(~url=urlToRedirect))
}
