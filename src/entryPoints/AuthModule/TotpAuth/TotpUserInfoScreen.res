@react.component
let make = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let userInfo = async () => {
    // open HSwitchLoginUtils
    open LogicUtils
    try {
      // TODO: user info api call
      let url = getURL(~entityName=USERS, ~userType=#USER_INFO, ~methodType=Get, ())
      let response = await fetchDetails(url)
      let email = response->getDictFromJsonObject->getString("email", "")
      TotpUtils.parseResponseJson(~json=response, ~email)

      // TODO : check where to get Token in this case
      let tokenDetails = TotpUtils.getSptTokenType()
      switch tokenDetails.token {
      | Some(token) =>
        setAuthStatus(LoggedIn(ToptAuth(TotpUtils.totpAuthInfoForToken(token, DASHBOARD_ENTRY))))

      | _ => setAuthStatus(LoggedOut)
      }
      setIsSidebarDetails("isPinned", false->JSON.Encode.bool)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect0(() => {
    userInfo()->ignore
    None
  })
  let onClick = () => {
    setAuthStatus(LoggedOut)
  }

  <PageLoaderWrapper screenState>
    <EmailVerifyScreen
      errorMessage onClick trasitionMessage="You will be redirecting to the dashboard.."
    />
  </PageLoaderWrapper>
}
