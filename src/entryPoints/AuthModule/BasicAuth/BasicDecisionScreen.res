@react.component
let make = () => {
  let flowType =
    Some(HSLocalStorage.getFromUserDetails("flow_type"))->BasicAuthUtils.flowTypeStrToVariantMapper
  switch flowType {
  | MERCHANT_SELECT => <AcceptInvite />
  | DASHBOARD_ENTRY
  | ERROR =>
    <HyperSwitchApp />
  }
}
