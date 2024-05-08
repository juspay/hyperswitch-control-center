@react.component
let make = () => {
  open HyperSwitchAuthTypes
  open APIUtils

  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let fetchDetails = APIUtils.useGetMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let userInfo = async () => {
    open HSwitchLoginUtils
    open LogicUtils
    try {
      // TODO: user info api call
      let token = getSptTokenType()
      let url = getURL(~entityName=USERS, ~userType=#USER_INFO, ~methodType=Get, ())
      Js.log2("url", url)
      let response = await fetchDetails(url)
      let email = response->getDictFromJsonObject->getString("email", "")
      let token = HyperSwitchAuthUtils.parseResponseJson(~json=response, ~email)
      setAuthStatus(LoggedIn(HSwitchLoginUtils.getDummyAuthInfoForToken(token, DASHBOARD_ENTRY)))
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  React.useEffect0(() => {
    Js.log("Log in User Infi")
    userInfo()->ignore
    None
  })

  <TransitionScreen errorMessage transitionMessage="You will be redirecting to the Dashboard.." />
}
