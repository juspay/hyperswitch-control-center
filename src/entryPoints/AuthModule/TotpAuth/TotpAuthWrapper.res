@react.component
let make = (~children) => {
  open APIUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let authLogic = () => {
    open TotpUtils

    let tokenDetails = getSptTokenType()

    switch tokenDetails.token {
    | Some(token) =>
      if !(token->LogicUtils.isEmptyString) {
        Js.log(tokenDetails)
        setAuthStatus(
          LoggedIn(ToptAuth(TotpUtils.totpAuthInfoForToken(token, tokenDetails.token_type))),
        )
      } else {
        setAuthStatus(LoggedOut)
      }
    | None => setAuthStatus(LoggedOut)
    }
  }

  let fetchDetails = async () => {
    open CommonAuthUtils
    open LogicUtils
    try {
      let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")
      let url = getURL(~entityName=USERS, ~userType=#FROM_EMAIL, ~methodType=Post, ())

      switch tokenFromUrl {
      | Some(token) => {
          let response = await updateDetails(url, token->generateBodyForEmailRedirection, Post, ())

          let flowType = response->getDictFromJsonObject->getString("token_type", "")

          let flowVariant =
            flowType->String.length > 0
              ? Some(flowType)->TotpUtils.flowTypeStrToVariantMapper
              : ERROR

          let responseToken = response->getDictFromJsonObject->getString("token", "")

          setAuthStatus(
            LoggedIn(ToptAuth(TotpUtils.totpAuthInfoForToken(responseToken, flowVariant))),
          )
          RescriptReactRouter.replace(
            HSwitchGlobalVars.appendDashboardPath(
              ~url=`/${flowVariant->TotpUtils.variantToStringFlowMapper}?token=${token}`,
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
      fetchDetails()->ignore

    | _ => authLogic()
    }

    None
  })

  <div className="font-inter-style">
    {switch authStatus {
    | LoggedOut => <TotpAuthScreen setAuthStatus />
    | LoggedIn(_token) => children
    | CheckingAuthStatus => <Loader />
    }}
  </div>
}
