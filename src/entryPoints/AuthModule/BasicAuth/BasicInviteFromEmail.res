@react.component
let make = (~setAuthType, ~setAuthStatus) => {
  open APIUtils
  open LogicUtils
  open AuthProviderTypes
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)

  let acceptInviteFormEmail = async body => {
    try {
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType=#ACCEPT_INVITE_FROM_EMAIL, ())
      let res = await updateDetails(url, body, Post, ())
      let typedAuthInfo = res->BasicAuthUtils.setLoginResToStorage
      if typedAuthInfo.token->Option.isSome && typedAuthInfo.email->Option.isSome {
        setAuthStatus(LoggedIn(BasicAuth(typedAuthInfo)))
        setIsSidebarDetails("isPinned", false->JSON.Encode.bool)
        RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/home"))
      } else {
        setAuthStatus(LoggedOut)
        RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
      }
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
    let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")

    switch tokenFromUrl {
    | Some(token) => token->generateBodyForEmailRedirection->acceptInviteFormEmail->ignore
    | None => setErrorMessage(_ => "Token not received")
    }

    None
  })
  let onClick = () => {
    RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
    setAuthType(_ => CommonAuthTypes.LoginWithEmail)
  }

  <EmailVerifyScreen
    errorMessage
    onClick
    trasitionMessage="Accepting invite... You will be redirecting to the Dashboard.."
  />
}
