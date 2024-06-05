open TotpTypes

let flowTypeStrToVariantMapper = val => {
  switch val {
  // old types
  | Some("merchant_select") => MERCHANT_SELECT
  | Some("dashboard_entry") => DASHBOARD_ENTRY

  | Some("totp") => TOTP

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
  switch val {
  | DASHBOARD_ENTRY => "dashboard_entry"
  | MERCHANT_SELECT => "merchant_select"
  | TOTP => "totp"
  | FORCE_SET_PASSWORD => "force_set_password"
  | ACCEPT_INVITE => "accept_invite"
  | VERIFY_EMAIL => "verify_email"
  | ACCEPT_INVITATION_FROM_EMAIL => "accept_invitation_from_email"
  | RESET_PASSWORD => "reset_password"
  | USER_INFO => "user_info"
  | ERROR => ""
  }
}

let getEmailTmpToken = () => {
  LocalStorage.getItem("email_token")->Nullable.toOption
}

let storeEmailTokenTmp = emailToken => {
  LocalStorage.setItem("email_token", emailToken)
}

let getEmailTokenValue = email_token => {
  let tmpEmailToken = getEmailTmpToken()
  switch email_token {
  | Some(email_token) => Some(email_token)
  | None => tmpEmailToken
  }
}

let getTotpAuthInfo = (~email_token=None, json) => {
  open LogicUtils
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let totpInfo = {
    email: getOptionString(dict, "email"),
    merchant_id: getOptionString(dict, "merchant_id"),
    name: getOptionString(dict, "name"),
    token: getOptionString(dict, "token"),
    role_id: getOptionString(dict, "role_id"),
    token_type: dict->getOptionString("token_type"),
    email_token: email_token->getEmailTokenValue,
    is_two_factor_auth_setup: getOptionBool(dict, "is_two_factor_auth_setup"),
    recovery_codes_left: getOptionInt(dict, "recovery_codes_left"),
  }
  switch email_token {
  | Some(emailTk) => emailTk->storeEmailTokenTmp
  | None => ()
  }
  totpInfo
}

let setTotpAuthResToStorage = json => {
  LocalStorage.setItem("USER_INFO", json->JSON.stringifyAny->Option.getOr(""))
}

let getTotputhInfoFromStrorage = () => {
  open LogicUtils
  let json = LocalStorage.getItem("USER_INFO")->getValFromNullableValue("")->safeParse
  json->getTotpAuthInfo
}

let getEmailToken = (authStatus: AuthProviderTypes.authStatus) => {
  switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | TotpAuth(totpInfo) => totpInfo.email_token
    | _ => None
    }
  | _ => None
  }
}

let validateTotpForm = (values: JSON.t, keys: array<string>) => {
  let valuesDict = values->LogicUtils.getDictFromJsonObject

  let errors = Dict.make()
  keys->Array.forEach(key => {
    let value = LogicUtils.getString(valuesDict, key, "")

    // empty check
    if value->LogicUtils.isEmptyString {
      switch key {
      | "email" => Dict.set(errors, key, "Please enter your Email ID"->JSON.Encode.string)
      | "password" => Dict.set(errors, key, "Please enter your Password"->JSON.Encode.string)
      | "create_password" => Dict.set(errors, key, "Please enter your Password"->JSON.Encode.string)
      | "comfirm_password" =>
        Dict.set(errors, key, "Please enter your Password Once Again"->JSON.Encode.string)
      | _ =>
        Dict.set(
          errors,
          key,
          `${key->LogicUtils.capitalizeString} cannot be empty`->JSON.Encode.string,
        )
      }
    }

    // email check
    if (
      value->LogicUtils.isNonEmptyString && key === "email" && value->CommonAuthUtils.isValidEmail
    ) {
      Dict.set(errors, key, "Please enter valid Email ID"->JSON.Encode.string)
    }

    // password check
    CommonAuthUtils.passwordKeyValidation(value, key, "create_password", errors)

    // confirm password check
    CommonAuthUtils.confirmPasswordCheck(
      value,
      key,
      "comfirm_password",
      "create_password",
      valuesDict,
      errors,
    )
  })

  errors->JSON.Encode.object
}

let downloadRecoveryCodes = (~recoveryCodes) => {
  open LogicUtils
  DownloadUtils.downloadOld(
    ~fileName="recoveryCodes.txt",
    ~content=JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3),
  )
}
