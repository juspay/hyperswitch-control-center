@react.component
let make = () => {
  open AuthProviderTypes
  open APIUtils

  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let verifyEmailWithSPT = async body => {
    try {
      open TotpUtils
      open LogicUtils
      let url = getURL(
        ~entityName=USERS,
        ~methodType=Post,
        ~userType={#VERIFY_EMAILV2_TOKEN_ONLY},
        (),
      )
      let res = await updateDetails(url, body, Post, ())

      let token_type =
        res->getDictFromJsonObject->getOptionString("token_type")->flowTypeStrToVariantMapper
      let token = res->getDictFromJsonObject->getString("token", "")
      setAuthStatus(LoggedIn(ToptAuth(TotpUtils.totpAuthInfoForToken(token, token_type))))
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

    let emailToken = authStatus->getEmailToken

    switch emailToken {
    | Some(token) => token->generateBodyForEmailRedirection->verifyEmailWithSPT->ignore
    | None => setErrorMessage(_ => "Token not received")
    }

    None
  })
  let onClick = () => {
    RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
  }

  <EmailVerifyScreen
    errorMessage onClick trasitionMessage="Verifing... You will be redirecting.."
  />
}
