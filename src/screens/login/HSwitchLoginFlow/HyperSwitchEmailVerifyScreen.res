@react.component
let make = () => {
  open HyperSwitchAuthTypes
  open APIUtils
  open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let emailVerifyUpdate = async body => {
    try {
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType={#VERIFY_EMAILV2}, ())
      let res = await updateDetails(url, body, Post, ())
      let email = res->JSON.Decode.object->Option.getOr(Dict.make())->getString("email", "")
      let token = HyperSwitchAuthUtils.parseResponseJson(~json=res, ~email)
      await HyperSwitchUtils.delay(1000)
      if !(token->isEmptyString) && !(email->isEmptyString) {
        setAuthStatus(LoggedIn(HSwitchLoginUtils.getDummyAuthInfoForToken(token, DASHBOARD_ENTRY)))
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

  let verifEmailWithSPT = async body => {
    // TODO: Replace with the actual API and response
    try {
      open HSwitchLoginUtils
      let url = getURL(
        ~entityName=USERS,
        ~methodType=Post,
        ~userType={#VERIFY_EMAILV2_TOKEN_ONLY},
        (),
      )
      let res = await updateDetails(url, body, Post, ())
      let res =
        [("token", "asdfvadf"->JSON.Encode.string), ("token_type", "totp"->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object
      let token = "asdfvadf"
      let token_Type =
        res->getDictFromJsonObject->getOptionString("token_type")->flowTypeStrToVariantMapper
      setAuthStatus(LoggedIn(HSwitchLoginUtils.getDummyAuthInfoForToken(token, token_Type)))
      RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/user_info"))
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
        | true => bodyForRedirection->verifEmailWithSPT
        | _ => bodyForRedirection->emailVerifyUpdate
        }->ignore
      }
    | None => setErrorMessage(_ => "Token not received")
    }
    None
  })

  <TransitionScreen errorMessage transitionMessage="Verifing... You will be redirecting.." />
}
