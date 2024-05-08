open BasicAuthTypes
let flowTypeStrToVariantMapper = val => {
  open BasicAuthTypes
  switch val {
  | Some("merchant_select") => MERCHANT_SELECT
  | Some("dashboard_entry") => DASHBOARD_ENTRY
  | Some(_) => ERROR
  | None => ERROR
  }
}

let parseResponseJson = (~json, ~email) => {
  open HSwitchUtils
  open LogicUtils
  let valuesDict = json->JSON.Decode.object->Option.getOr(Dict.make())
  let verificationValue = valuesDict->getOptionInt("verification_days_left")->Option.getOr(-1)
  let flowType = valuesDict->getOptionString("flow_type")
  let flowTypeVal = switch flowType {
  | Some(val) => val->JSON.Encode.string
  | None => JSON.Encode.null
  }

  if flowType->Option.isSome && flowType->flowTypeStrToVariantMapper === MERCHANT_SELECT {
    LocalStorage.setItem(
      "accept_invite_data",
      valuesDict->getArrayFromDict("merchants", [])->JSON.stringifyAny->Option.getOr(""),
    )
  }
  setUserDetails("flow_type", flowTypeVal)

  setMerchantDetails("merchant_id", valuesDict->getString("merchant_id", "")->JSON.Encode.string)
  setMerchantDetails("email", email->JSON.Encode.string)
  setMerchantDetails("verification", verificationValue->Int.toString->JSON.Encode.string)
  setUserDetails("name", valuesDict->getString("name", "")->JSON.Encode.string)
  setUserDetails("user_role", valuesDict->getString("user_role", "")->JSON.Encode.string)
  valuesDict->getString("token", "")
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
    if value->LogicUtils.isNonEmptyString && key === "email" && value->HSwitchUtils.isValidEmail {
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

module ToggleLiveTestMode = {
  open HSwitchGlobalVars
  open CommonAuthTypes
  @react.component
  let make = (~authType, ~mode, ~setMode, ~setAuthType, ~customClass="") => {
    let liveButtonRedirectUrl = getHostUrlWithBasePath
    let testButtonRedirectUrl = getHostUrlWithBasePath
    <>
      {switch authType {
      | LoginWithPassword
      | LoginWithEmail
      | LiveMode => {
          let borderStyle = "border-b-1 border-grey-600 border-opacity-50"
          let selectedtStyle = "border-b-2 inline-block relative -bottom-px py-2"
          let testModeStyles = mode === TestButtonMode ? selectedtStyle : ""
          let liveModeStyles = mode === LiveButtonMode ? selectedtStyle : ""

          <FramerMotion.Motion.Div
            transition={{duration: 0.3}} layoutId="toggle" className="w-full">
            <div className={`w-full p-2 ${customClass} `}>
              <div className={`flex items-center ${borderStyle} gap-4`}>
                <div
                  className={`!shadow-none text-white text-start text-fs-16 font-semibold cursor-pointer flex justify-center`}
                  onClick={_ => {
                    setMode(_ => TestButtonMode)
                    setAuthType(_ => LoginWithEmail)
                    Window.Location.replace(testButtonRedirectUrl)
                  }}>
                  <span className={`${testModeStyles}`}> {"Test Mode"->React.string} </span>
                </div>
                <div
                  className={`!shadow-none text-white text-start text-fs-16 font-semibold cursor-pointer flex justify-center`}
                  onClick={_ => {
                    setMode(_ => LiveButtonMode)
                    setAuthType(_ => LoginWithEmail)
                    Window.Location.replace(liveButtonRedirectUrl)
                  }}>
                  <span className={`${liveModeStyles}`}> {"Live Mode"->React.string} </span>
                </div>
              </div>
            </div>
          </FramerMotion.Motion.Div>
        }

      | _ => React.null
      }}
    </>
  }
}
