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
      | "confirm_password" =>
        Dict.set(errors, key, "Please enter your Password Once Again"->JSON.Encode.string)
      | _ =>
        Dict.set(
          errors,
          key,
          `${key
            ->LogicUtils.capitalizeString
            ->LogicUtils.snakeToTitle} cannot be empty`->JSON.Encode.string,
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
    switch key {
    | "password" => CommonAuthUtils.passwordKeyValidation(value, key, "password", errors)
    | "new_password" => CommonAuthUtils.passwordKeyValidation(value, key, "new_password", errors)
    | _ => CommonAuthUtils.passwordKeyValidation(value, key, "create_password", errors)
    }

    // confirm password check
    CommonAuthUtils.confirmPasswordCheck(
      value,
      key,
      "confirm_password",
      "create_password",
      valuesDict,
      errors,
    )
    //confirm password check for #change_password
    CommonAuthUtils.confirmPasswordCheck(
      value,
      key,
      "confirm_password",
      "new_password",
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

let jsonToTwoFaValueType: Dict.t<'a> => TwoFaTypes.twoFaValueType = dict => {
  open LogicUtils

  {
    isCompleted: dict->getBool("is_completed", false),
    attemptsRemaining: dict->getInt("remaining_attempts", 4),
  }
}

let jsonTocheckTwofaResponseType: JSON.t => TwoFaTypes.checkTwofaResponseType = json => {
  open LogicUtils
  let jsonToDict = json->getDictFromJsonObject

  let statusValueDict = jsonToDict->Dict.get("status")
  let isSkippable = jsonToDict->getBool("is_skippable", true)

  let statusValue = switch statusValueDict {
  | Some(json) => {
      let dict = json->getDictFromJsonObject
      let twoFaValue: TwoFaTypes.twoFatype = {
        totp: dict->getDictfromDict("totp")->jsonToTwoFaValueType,
        recoveryCode: dict->getDictfromDict("recovery_code")->jsonToTwoFaValueType,
      }
      Some(twoFaValue)
    }
  | None => None
  }

  {
    status: statusValue,
    isSkippable,
  }
}
