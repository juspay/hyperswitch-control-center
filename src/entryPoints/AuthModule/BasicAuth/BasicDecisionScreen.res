@react.component
let make = () => {
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | BasicAuth(basicInfo) => basicInfo.flow_type->BasicAuthUtils.flowTypeStrToVariantMapper
    | _ => DASHBOARD_ENTRY
    }
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    setAuthStatus(LoggedOut)
  }
  switch flowType {
  | MERCHANT_SELECT => <AcceptInvite />
  | DASHBOARD_ENTRY => <HyperSwitchApp />
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
