@react.component
let make = (~setAuthType, ~setAuthStatus) => {
  open AuthProviderTypes
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let emailVerifyUpdate = async body => {
    try {
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType={#VERIFY_EMAILV2}, ())
      let res = await updateDetails(url, body, Post, ())
      let email = res->JSON.Decode.object->Option.getOr(Dict.make())->getString("email", "")
      let token = BasicAuthUtils.parseResponseJson(~json=res, ~email)
      await HyperSwitchUtils.delay(1000)
      if !(token->isEmptyString) && !(email->isEmptyString) {
        setAuthStatus(LoggedIn(BasicAuth(BasicAuthTypes.getDummyAuthInfoForToken(token))))
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
    | Some(token) => token->generateBodyForEmailRedirection->emailVerifyUpdate->ignore
    | None => setErrorMessage(_ => "Token not received")
    }
    None
  })
  let onClick = () => {
    RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
    setAuthType(_ => CommonAuthTypes.LoginWithEmail)
  }

  <EmailVerifyScreen
    errorMessage onClick trasitionMessage="Verifing... You will be redirecting.."
  />
}
