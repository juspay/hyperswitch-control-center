let getTwoFaEnumFromString = string_value => {
  open HSwitchSettingTypes
  switch string_value {
  | Some("reset_totp") => ResetTotp
  | Some("regenerate_recovery_codes") => RegenerateRecoveryCodes
  | Some(_) | None => ResetTotp
  }
}
