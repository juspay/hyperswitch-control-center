@react.component
let make = () => {
  open AuthProviderTypes
  open APIUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let acceptInviteFromEmailWithSPT = async body => {
    try {
      open TotpUtils
      open LogicUtils
      // TODO: Replace with the actual API and response
      let url = getURL(
        ~entityName=USERS,
        ~methodType=Post,
        ~userType={#ACCEPT_INVITE_FROM_EMAIL_TOKEN_ONLY},
        (),
      )
      let res = await updateDetails(url, body, Post, ())
      let token_Type =
        res->getDictFromJsonObject->getOptionString("token_type")->flowTypeStrToVariantMapper
      let token = res->getDictFromJsonObject->getString("token", "")
      setAuthStatus(LoggedIn(ToptAuth(TotpUtils.totpAuthInfoForToken(token, token_Type))))
      RescriptReactRouter.replace(
        HSwitchGlobalVars.appendDashboardPath(~url=`/${token_Type->variantToStringFlowMapper}`),
      )
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect0(() => {
    open LogicUtils
    open CommonAuthUtils

    let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")

    switch tokenFromUrl {
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
