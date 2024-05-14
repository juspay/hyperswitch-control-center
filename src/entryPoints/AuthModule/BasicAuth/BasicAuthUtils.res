open BasicAuthTypes
open LogicUtils
let flowTypeStrToVariantMapper = val => {
  switch val {
  | Some("merchant_select") => MERCHANT_SELECT
  | Some("dashboard_entry") => DASHBOARD_ENTRY
  | Some(_) => DASHBOARD_ENTRY
  | None => DASHBOARD_ENTRY
  }
}

let getAuthInfo = json => {
  let dict = json->JsonFlattenUtils.flattenObject(false)
  let authInfo = {
    email: getOptionString(dict, "email"),
    flowType: getOptionString(dict, "flow_type"),
    merchantId: getOptionString(dict, "merchant_id"),
    username: getOptionString(dict, "name"),
    token: getOptionString(dict, "token"),
    userRole: getOptionString(dict, "user_role"),
    verificationDaysLeft: getOptionBool(dict, "verification_days_left"),
    acceptInviteData: getOptionalArrayFromDict(dict, "merchants"),
  }
  authInfo
}

let setLoginResToStorage = json => {
  LocalStorage.setItem("USER_INFO", json->JSON.stringifyAny->Option.getOr(""))
  json->getAuthInfo
}

let getBasicAuthInfo = () => {
  let json = LocalStorage.getItem("USER_INFO")->getValFromNullableValue("")->safeParse
  json->getAuthInfo
}

let parseResponseJson = (~json) => {
  let valuesDict = json->JSON.Decode.object->Option.getOr(Dict.make())

  let flowType = valuesDict->getOptionString("flow_type")

  if flowType->Option.isSome && flowType->flowTypeStrToVariantMapper === MERCHANT_SELECT {
    LocalStorage.setItem(
      "accept_invite_data",
      valuesDict->getArrayFromDict("merchants", [])->JSON.stringifyAny->Option.getOr(""),
    )
  }
}

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
