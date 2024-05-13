@react.component
let make = () => {
  open HSwitchUtils
  open APIUtils
  open LogicUtils
  let flowType =
    Some(HSLocalStorage.getFromUserDetails("flow_type"))->BasicAuthUtils.flowTypeStrToVariantMapper
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let updateDetails = useUpdateMethod()
  let (merchantData, setMerchantData) = React.useState(_ => [])
  let merchantDataJsonFromLocalStorage =
    LocalStorage.getItem("accept_invite_data")->getValFromNullableValue("")->safeParse

  let logoutUser = () => {
    LocalStorage.clear()
    setAuthStatus(LoggedOut)
  }

  React.useEffect0(() => {
    switch JSON.Classify.classify(merchantDataJsonFromLocalStorage) {
    | Array(arr) =>
      if arr->Array.length > 0 {
        setMerchantData(_ => arr)
      } else {
        logoutUser()
      }
    | _ => logoutUser()
    }

    None
  })

  React.useEffect1(() => {
    if flowType === MERCHANT_SELECT {
      RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/accept-invite"))
    } else {
      setDashboardPageState(_ => #HOME)
      RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/home"))
    }
    None
  }, [flowType])

  let onClickLoginToDashboard = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#ACCEPT_INVITE, ~methodType=Post, ())
      let acceptedMerchantIds = merchantData->Array.reduce([], (acc, ele) => {
        let merchantDataDict = ele->getDictFromJsonObject
        if merchantDataDict->getBool("is_active", false) {
          acc->Array.push(merchantDataDict->getString("merchant_id", "")->JSON.Encode.string)
        }
        acc
      })
      let body =
        [
          ("merchant_ids", acceptedMerchantIds->JSON.Encode.array),
          ("need_dashboard_entry_response", true->JSON.Encode.bool),
        ]->getJsonFromArrayOfJson
      let res = await updateDetails(url, body, Post, ())
      let email = HSLocalStorage.getFromMerchantDetails("email")
      let token = BasicAuthUtils.parseResponseJson(~json=res, ~email)
      LocalStorage.setItem("login", token)
      LocalStorage.removeItem("accept_invite_data")
      setUserDetails("flow_type", "dashboard_entry"->JSON.Encode.string)
      setDashboardPageState(_ => #HOME)
    } catch {
    | _ => ()
    }
  }

  let acceptInviteUpdate = index => {
    let merchantDataUpdated =
      merchantData
      ->JSON.stringifyAny
      ->Option.getOr("")
      ->safeParse
      ->JSON.Decode.array
      ->Option.getOr([])

    merchantDataUpdated
    ->getValueFromArray(index, JSON.Encode.null)
    ->getDictFromJsonObject
    ->Dict.set("is_active", true->JSON.Encode.bool)

    setMerchantData(_ => merchantDataUpdated)
  }

  <CommonInviteScreen
    merchantData acceptInviteOnClick={acceptInviteUpdate} onClickLoginToDashboard
  />
}
