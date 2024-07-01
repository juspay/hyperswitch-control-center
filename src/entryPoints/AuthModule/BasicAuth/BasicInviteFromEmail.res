@react.component
let make = (~setAuthType) => {
  open APIUtils
  open LogicUtils
  open AuthProviderTypes
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let getURL = useGetURL()
  let handleLogout = useHandleLogout()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)

  let acceptInviteFormEmail = async body => {
    try {
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType=#ACCEPT_INVITE_FROM_EMAIL, ())
      let res = await updateDetails(url, body, Post, ())
      setAuthStatus(LoggedIn(BasicAuth(res->BasicAuthUtils.getBasicAuthInfo)))
      setIsSidebarDetails("isPinned", false->JSON.Encode.bool)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        setErrorMessage(_ => err)
        handleLogout()->ignore
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
    setAuthType(_ => CommonAuthTypes.LoginWithEmail)
    handleLogout()->ignore
  }

  <EmailVerifyScreen
    errorMessage
    onClick
    trasitionMessage="Accepting invite... You will be redirecting to the Dashboard.."
  />
}
