open HyperSwitchAuthTypes
@react.component
let make = (~children) => {
  open APIUtils

  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let authLogic = () => {
    open HSwitchLoginUtils

    let tokenDetails = getSptTokenType()

    switch tokenDetails.token {
    | Some(token) =>
      if !(token->LogicUtils.isEmptyString) {
        setAuthStatus(
          LoggedIn(HSwitchLoginUtils.getDummyAuthInfoForToken(token, tokenDetails.token_type)),
        )
      } else {
        setAuthStatus(LoggedOut)
      }
    | None => setAuthStatus(LoggedOut)
    }
  }

  let fetchDetails = async () => {
    open HSwitchLoginUtils
    open LogicUtils
    try {
      let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")
      let url = getURL(~entityName=USERS, ~userType=#FROM_EMAIL, ~methodType=Post, ())

      switch tokenFromUrl {
      | Some(token) => {
          let response = await updateDetails(
            url,
            token->HyperSwitchAuthUtils.generateBodyForEmailRedirection,
            Post,
            (),
          )

          let flowType = response->getDictFromJsonObject->getString("token_type", "")

          let flowVariant =
            flowType->String.length > 0
              ? Some(flowType)->HSwitchLoginUtils.flowTypeStrToVariantMapper
              : ERROR

          let responseToken = response->getDictFromJsonObject->getString("token", "")
          setAuthStatus(
            LoggedIn(HSwitchLoginUtils.getDummyAuthInfoForToken(responseToken, flowVariant)),
          )
          RescriptReactRouter.replace(
            HSwitchGlobalVars.appendDashboardPath(
              ~url=`/${flowVariant->variantToStringFlowMapper}?token=${token}`,
            ),
          )
        }
      | None => setAuthStatus(LoggedOut)
      }
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  React.useEffect0(() => {
    switch url.path {
    | list{"user", "login"}
    | list{"register"} =>
      setAuthStatus(LoggedOut)

    | list{"user", "verify_email"}
    | list{"user", "set_password"}
    | list{"user", "accept_invite_from_email"} =>
      featureFlagDetails.newAuthEnabled ? fetchDetails()->ignore : setAuthStatus(LoggedOut)

    | _ => authLogic()
    }

    None
  })

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut => <HyperSwitchAuthScreen setAuthStatus />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <Loader />
    }}
  </div>
}
