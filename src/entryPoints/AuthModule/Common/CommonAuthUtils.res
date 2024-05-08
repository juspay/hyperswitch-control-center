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
      if !Js.Re.test_(%re("/^(?=.*[A-Z])/"), value) {
        mustHave->Array.push("uppercase")
      }
      if !Js.Re.test_(%re("/^(?=.*[a-z])/"), value) {
        mustHave->Array.push("lowercase")
      }
      if !Js.Re.test_(%re("/^(?=.*[0-9])/"), value) {
        mustHave->Array.push("numeric")
      }
      if !Js.Re.test_(%re("/^(?=.*[!@#$%^&*_])/"), value) {
        mustHave->Array.push("special")
      }
      if mustHave->Array.length > 0 {
        Dict.set(
          errors,
          key,
          `Your password is not strong enough. A good password must contain atleast ${mustHave->Array.joinWith(
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
    !Js.Option.equal(
      (. a, b) => a == b,
      Dict.get(valuesDict, passwordKey),
      Dict.get(valuesDict, key),
    )
  ) {
    Dict.set(errors, key, "The New password does not match!"->JSON.Encode.string)
  }
}

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
