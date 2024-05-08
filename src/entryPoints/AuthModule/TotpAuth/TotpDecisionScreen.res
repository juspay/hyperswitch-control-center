@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let flowType = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | ToptAuth(totpInfo) => totpInfo.token_type
    | _ => ERROR
    }
  | _ => ERROR
  }

  let onClick = () => {
    // TO DO
    Js.log("Implement onError")
  }

  switch (flowType, url.path->HSwitchUtils.urlPath) {
  | (MERCHANT_SELECT, list{"merchant_select"}) | (ACCEPT_INVITE, list{"accept-invite"}) =>
    <AcceptInvite />
  | (TOTP_SETUP, _) => <TotpSetup />
  | (FORCE_SET_PASSWORD, list{"force_set_password"}) | (RESET_PASSWORD, list{"reset_password"}) =>
    <> </>
  | (ACCEPT_INVITATION_FROM_EMAIL, list{"accept_invite_from_email"}) => <> </>
  | (VERIFY_EMAIL, list{"verify_email"}) => <TotpEmailVerifyScreen />
  | (USER_INFO, list{"user_info"}) => <TotpUserInfoScreen />
  | (DASHBOARD_ENTRY, _) => <HyperSwitchApp />
  | (ERROR, _) | (_, _) => <> </>
  }
}
