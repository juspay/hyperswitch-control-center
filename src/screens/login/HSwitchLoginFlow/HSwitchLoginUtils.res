let flowTypeStrToVariantMapper = val => {
  open HyperSwitchAuthTypes
  switch val {
  | Some("merchant_select") => MERCHANT_SELECT
  | Some("dashboard_entry") => DASHBOARD_ENTRY
  | Some(_) => ERROR
  | None => ERROR
  }
}
