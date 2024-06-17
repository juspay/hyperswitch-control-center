open TwoFaTypes

let flowTypeStrToVariantMapper = val => {
  switch val {
  // old types
  | Some("merchant_select") => MERCHANT_SELECT

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

let flowTypeStrToVariantMapperForNewFlow = val => {
  switch val {
  // old types
  | "merchant_select" => MERCHANT_SELECT
  | "totp" => TOTP
  // rotate password
  | "force_set_password" => FORCE_SET_PASSWORD
  // merchant select
  | "accept_invite" => ACCEPT_INVITE
  | "accept_invitation_from_email" => ACCEPT_INVITATION_FROM_EMAIL
  | "verify_email" => VERIFY_EMAIL
  | "reset_password" => RESET_PASSWORD
  // home call
  | "user_info" => USER_INFO
  | _ => ERROR
  }
}

let variantToStringFlowMapper = val => {
  switch val {
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

let getEmailTokenValue = email_token => {
  let tmpEmailToken = getEmailTmpToken()
  switch email_token {
  | Some(email_token) => Some(email_token)
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
  switch email_token {
  | Some(emailTk) => emailTk->AuthUtils.storeEmailTokenTmp
  | None => ()
  }
  preLoginInfo
}

let setTotpAuthResToStorage = json => {
  LocalStorage.setItem("USER_INFO", json->JSON.stringifyAny->Option.getOr(""))
}

let getTotpPreLoginInfoFromStorage = () => {
  open LogicUtils
  let json = LocalStorage.getItem("USER_INFO")->getValFromNullableValue("")->safeParse
  json->getPreLoginInfo
}

let getTotpAuthInfoFromStrorage = () => {
  open LogicUtils
  let json = LocalStorage.getItem("USER_INFO")->getValFromNullableValue("")->safeParse
  json->AuthUtils.getAuthInfo
}

let getEmailToken = (authStatus: AuthProviderTypes.authStatus) => {
  switch authStatus {
  | PreLogin(preLoginValue) => preLoginValue.email_token
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
