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

let divider =
  <div className="flex gap-2 items-center ">
    <hr className="w-full" />
    <p className=" text-gray-400"> {"OR"->React.string} </p>
    <hr className="w-full" />
  </div>
