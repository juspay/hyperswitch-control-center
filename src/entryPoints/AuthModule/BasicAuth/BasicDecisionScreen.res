@react.component
let make = () => {
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | BasicAuth(basicInfo) => basicInfo.flowType->BasicAuthUtils.flowTypeStrToVariantMapper
    | _ => DASHBOARD_ENTRY
    }
  | _ => ERROR
  }
  switch flowType {
  | MERCHANT_SELECT => <AcceptInvite />
  | DASHBOARD_ENTRY => <HyperSwitchApp />
  | ERROR => <> </>
  }
}
