@react.component
let make = () => {
  open AuthProviderTypes
  open APIUtils
  let getURL = useGetURL()

  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let acceptInviteFromEmailWithSPT = async body => {
    try {
      open TotpUtils

      let url = getURL(
        ~entityName=USERS,
        ~methodType=Post,
        ~userType={#ACCEPT_INVITE_FROM_EMAIL_TOKEN_ONLY},
        (),
      )
      let res = await updateDetails(url, body, Post, ())
      setAuthStatus(PreLogin(getPreLoginInfo(res)))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect0(() => {
    open CommonAuthUtils
    open TotpUtils
    open HSwitchGlobalVars
    RescriptReactRouter.replace(appendDashboardPath(~url="/accept_invite_from_email"))
    let emailToken = authStatus->getEmailToken

    switch emailToken {
    | Some(token) => token->generateBodyForEmailRedirection->acceptInviteFromEmailWithSPT->ignore
    | None => setErrorMessage(_ => "Token not received")
    }

    None
  })
  let onClick = () => {
    RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
  }

  <EmailVerifyScreen
    errorMessage
    onClick
    trasitionMessage="Accepting invite... You will be redirecting to the Dashboard.."
  />
}
