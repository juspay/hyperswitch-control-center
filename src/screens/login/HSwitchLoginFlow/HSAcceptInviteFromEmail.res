@react.component
let make = () => {
  open HyperSwitchAuthTypes
  open APIUtils
  open LogicUtils
  open HSwitchLoginUtils

  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let acceptInviteFormEmail = async body => {
    try {
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType=#ACCEPT_INVITE_FROM_EMAIL, ())
      let res = await updateDetails(url, body, Post, ())
      let email = res->JSON.Decode.object->Option.getOr(Dict.make())->getString("email", "")
      let token = HyperSwitchAuthUtils.parseResponseJson(~json=res, ~email)

      if !(token->isEmptyString) && !(email->isEmptyString) {
        setAuthStatus(LoggedIn(getDummyAuthInfoForToken(token, DASHBOARD_ENTRY)))
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

  let acceptInviteFromEmailWithSPT = async body => {
    try {
      // TODO: Replace with the actual API and response
      let url = getURL(
        ~entityName=USERS,
        ~methodType=Post,
        ~userType={#ACCEPT_INVITE_FROM_EMAIL_TOKEN_ONLY},
        (),
      )
      let res = await updateDetails(url, body, Post, ())
      let res =
        [("token", "asdfvadf"->JSON.Encode.string), ("token_type", "user_info"->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object
      let token = "asdfvadf"
      let token_Type =
        res->getDictFromJsonObject->getOptionString("token_type")->flowTypeStrToVariantMapper
      setAuthStatus(LoggedIn(getDummyAuthInfoForToken(token, token_Type)))
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
    open HyperSwitchAuthUtils

    let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")

    switch tokenFromUrl {
    | Some(token) => {
        let bodyForRedirection = token->generateBodyForEmailRedirection

        switch featureFlagDetails.newAuthEnabled {
        | true => bodyForRedirection->acceptInviteFromEmailWithSPT
        | _ => bodyForRedirection->acceptInviteFormEmail
        }->ignore
      }
    | None => setErrorMessage(_ => "Token not received")
    }

    None
  })

  <TransitionScreen
    errorMessage transitionMessage="Accepting invite... You will be redirecting to the Dashboard.."
  />
}
