@react.component
let make = (~onClick) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus, authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let token = switch authStatus {
  | PreLogin(preLoginInfo) => preLoginInfo.token
  | _ => None
  }
  let userInfo = async () => {
    open LogicUtils
    open HSLocalStorage

    try {
      let url = getURL(~entityName=USERS, ~userType=#USER_INFO, ~methodType=Get, ())
      let response = await fetchDetails(url)
      let dict = response->getDictFromJsonObject
      dict->Dict.set("token", token->Option.getOr("")->JSON.Encode.string)
      let info = AuthUtils.getAuthInfo(dict->JSON.Encode.object)
      setAuthStatus(LoggedIn(Auth(info)))
      setIsSidebarDetails("isPinned", false->JSON.Encode.bool)
      removeItemFromLocalStorage(~key="PRE_LOGIN_INFO")
      removeItemFromLocalStorage(~key="email_token")
      removeItemFromLocalStorage(~key="code")
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

  <PageLoaderWrapper screenState>
    <EmailVerifyScreen
      errorMessage onClick trasitionMessage="You will be redirecting to the dashboard.."
    />
  </PageLoaderWrapper>
}
