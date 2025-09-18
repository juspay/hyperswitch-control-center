let getTwoFaEnumFromString = string_value => {
  open HSwitchSettingTypes
  switch string_value {
  | Some("reset_totp") => ResetTotp
  | Some("regenerate_recovery_code") => RegenerateRecoveryCode
  | Some(_) | None => ResetTotp
  }
}

let typedValueForCheckStatus = dict => {
  open HSwitchSettingTypes
  open LogicUtils
  {
    totp: dict->getBool("totp", false),
    recovery_code: dict->getBool("recovery_code", false),
  }
}
