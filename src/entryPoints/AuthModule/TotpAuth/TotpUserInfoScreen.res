@react.component
let make = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus, authStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let token = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | TotpAuth(totpInfo) => totpInfo.token
    | _ => None
    }
  | _ => None
  }
  let userInfo = async () => {
    open LogicUtils
    open TotpTypes
    open TotpUtils
    try {
      let url = getURL(~entityName=USERS, ~userType=#USER_INFO, ~methodType=Get, ())
      let response = await fetchDetails(url)
      let dict = response->getDictFromJsonObject
      dict->setOptionString("token", token)
      dict->Dict.set("token_type", DASHBOARD_ENTRY->variantToStringFlowMapper->JSON.Encode.string)
      let info = TotpUtils.getTotpAuthInfo(dict->JSON.Encode.object)
      setAuthStatus(LoggedIn(TotpAuth(info)))
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
