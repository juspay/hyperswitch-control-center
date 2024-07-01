@react.component
let make = () => {
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let handleLogout = APIUtils.useHandleLogout()

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | BasicAuth(basicInfo) => basicInfo.flow_type->BasicAuthUtils.flowTypeStrToVariantMapper
    | _ => DASHBOARD_ENTRY
    }
  | _ => ERROR
  }

  let onClickErrorPageButton = () => {
    handleLogout()->ignore
  }
  switch flowType {
  | MERCHANT_SELECT => <AcceptInvite />
  | DASHBOARD_ENTRY => <HyperSwitchApp />
  | ERROR => <CommonAuthError onClick=onClickErrorPageButton />
  }
}
