open CommonAuthTypes
let passwordKeyValidation = (value, key, keyVal, errors) => {
  let mustHave: array<string> = []
  if value->LogicUtils.isNonEmptyString && key === keyVal {
    if value->String.length < 8 {
      Dict.set(
        errors,
        key,
        "Your password is not strong enough. Password size must be more than 8"->JSON.Encode.string,
      )
    } else {
      if !RegExp.test(%re("/^(?=.*[A-Z])/"), value) {
        mustHave->Array.push("uppercase")
      }
      if !RegExp.test(%re("/^(?=.*[a-z])/"), value) {
        mustHave->Array.push("lowercase")
      }
      if !RegExp.test(%re("/^(?=.*[0-9])/"), value) {
        mustHave->Array.push("numeric")
      }

      /*
       Checks if the password contains one of the below special character: 
       ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', '{', '}', ';', "'", ':', '"', '\\', '|', ',', '.', '<', '>', '/', '?', '', '~'] 
 */
      if (
        !RegExp.test(
          RegExp.fromString("^(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~])"),
          value,
        )
      ) {
        mustHave->Array.push("special")
      }
      if RegExp.test(%re("/\s/"), value) {
        Dict.set(errors, key, `Password should not contain whitespaces.`->JSON.Encode.string)
      }
      if mustHave->Array.length > 0 {
        Dict.set(
          errors,
          key,
          `Your password is not strong enough. A good password must contain atleast ${mustHave->Array.joinWithUnsafe(
              ",",
            )} character`->JSON.Encode.string,
        )
      }
    }
  }
}

let confirmPasswordCheck = (value, key, confirmKey, passwordKey, valuesDict, errors) => {
  if (
    key === confirmKey &&
    value->LogicUtils.isNonEmptyString &&
    !Option.equal(Dict.get(valuesDict, passwordKey), Dict.get(valuesDict, key), (a, b) => a == b)
  ) {
    Dict.set(errors, key, "The New password does not match!"->JSON.Encode.string)
  }
}

let isValidEmail = value =>
  !RegExp.test(
    %re(`/^(([^<>()[\]\.,;:\s@"]+(\.[^<>()[\]\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/`),
    value,
  )

let getResetpasswordBodyJson = (password, token) =>
  [("password", password->JSON.Encode.string), ("token", token->JSON.Encode.string)]
  ->Dict.fromArray
  ->JSON.Encode.object

let getEmailPasswordBody = (email, password, country) =>
  [
    ("email", email->JSON.Encode.string),
    ("password", password->JSON.Encode.string),
    ("country", country->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

let getEmailBody = (email, ~country=?, ()) => {
  let fields = [("email", email->JSON.Encode.string)]

  switch country {
  | Some(value) => fields->Array.push(("country", value->JSON.Encode.string))->ignore
  | _ => ()
  }

  fields->Dict.fromArray->JSON.Encode.object
}

let generateBodyForEmailRedirection = token => {
  open LogicUtils
  [("token", token->JSON.Encode.string)]->getJsonFromArrayOfJson
}

let errorMapper = dict => {
  open LogicUtils
  {
    code: dict->getString("code", "UR_00"),
    message: dict->getString("message", "something went wrong"),
    type_: dict->getString("message", "something went wrong"),
  }
}

let parseErrorMessage = errorMessage => {
  let parsedValue = switch Exn.message(errorMessage) {
  | Some(msg) => msg->LogicUtils.safeParse
  | None => JSON.Encode.null
  }

  switch JSON.Classify.classify(parsedValue) {
  | Object(obj) => obj->errorMapper
  | String(_str) => Dict.make()->errorMapper
  | _ => Dict.make()->errorMapper
  }
}

let errorSubCodeMapper = (subCode: string) => {
  switch subCode {
  | "UR_01" => UR_01
  | "UR_03" => UR_03
  | "UR_05" => UR_05
  | "UR_16" => UR_16
  | "UR_29" => UR_29
  | "UR_38" => UR_38
  | "UR_40" => UR_40
  | "UR_41" => UR_41
  | "UR_42" => UR_42
  | _ => UR_00
  }
}

let clearLocalStorage = () => {
  LocalStorage.clear()
}

module ToggleLiveTestMode = {
  open GlobalVars
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
