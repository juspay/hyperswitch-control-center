open TotpTypes
let validateForm = (values: JSON.t, keys: array<string>) => {
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

let getSptTokenType: unit => TotpTypes.sptTokenType = () => {
  let token = LocalStorage.getItem("login")->Nullable.toOption
  let tokenType = LocalStorage.getItem("token_type")->Nullable.toOption->flowTypeStrToVariantMapper
  let emailToken = LocalStorage.getItem("email_token")->Nullable.toOption

  {
    token,
    token_type: tokenType,
    email_token: emailToken,
  }
}

let sptToken = (token, tokenType, email_token) => {
  LocalStorage.setItem("token_type", tokenType)

  switch email_token {
  | Some(token_value) => LocalStorage.setItem("email_token", token_value)
  | _ => ()
  }

  switch token {
  | Some(tok) => LocalStorage.setItem("login", tok)
  | _ => ()
  }
}

let getEmailTokenValue = email_token => {
  let sptToken = getSptTokenType()
  switch email_token {
  | Some(email_token) => Some(email_token)
  | None => sptToken.email_token
  }
}

let totpAuthInfoForToken = (~email_token=None, token, token_type) => {
  let totpInfo = {
    token,
    merchantId: None,
    username: None,
    email: None,
    userRole: None,
    token_type,
    email_token: email_token->getEmailTokenValue,
  }
  totpInfo
}

let setMerchantDetailsInLocalStorage = (key, value) => {
  let localStorageData = HSLocalStorage.getInfoFromLocalStorage(~lStorageKey="merchant")
  localStorageData->Dict.set(key, value)

  "merchant"->LocalStorage.setItem(localStorageData->JSON.stringifyAny->Option.getOr(""))
}

let setUserDetailsInLocalStorage = (key, value) => {
  let localStorageData = HSLocalStorage.getInfoFromLocalStorage(~lStorageKey="user")
  localStorageData->Dict.set(key, value)
  "user"->LocalStorage.setItem(localStorageData->JSON.stringifyAny->Option.getOr(""))
}

let parseResponseJson = (~json, ~email) => {
  open LogicUtils

  let valuesDict = json->JSON.Decode.object->Option.getOr(Dict.make())

  let verificationValue = valuesDict->getOptionInt("verification_days_left")->Option.getOr(-1)
  setMerchantDetailsInLocalStorage(
    "merchant_id",
    valuesDict->getString("merchant_id", "")->JSON.Encode.string,
  )
  setMerchantDetailsInLocalStorage("email", email->JSON.Encode.string)
  setMerchantDetailsInLocalStorage(
    "verification",
    verificationValue->Int.toString->JSON.Encode.string,
  )
  setUserDetailsInLocalStorage("name", valuesDict->getString("name", "")->JSON.Encode.string)
  setUserDetailsInLocalStorage(
    "user_role",
    valuesDict->getString("user_role", "")->JSON.Encode.string,
  )
}

let getEmailToken = (authStatus: AuthProviderTypes.authStatus) => {
  switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | ToptAuth(totpInfo) => totpInfo.email_token
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
