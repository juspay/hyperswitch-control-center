@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let showToast = ToastState.useShowToast()
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let updateDetails = useUpdateMethod()
  let (merchantData, setMerchantData) = React.useState(_ => [])
  let getURL = useGetURL()
  let handleLogout = useHandleLogout()

  React.useEffect0(() => {
    let acceptInvitedata = switch authStatus {
    | LoggedIn(info) =>
      switch info {
      | BasicAuth(basicInfo) => basicInfo.merchants
      | _ => None
      }
    | _ => None
    }

    switch acceptInvitedata {
    | Some(arr) =>
      if arr->Array.length > 0 {
        setMerchantData(_ => arr)
        RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/accept-invite"))
      } else {
        handleLogout()->ignore
      }
    | None => handleLogout()->ignore
    }

    None
  })

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
      let typedInfo = res->BasicAuthUtils.getBasicAuthInfo
      if typedInfo.token->Option.isSome {
        open AuthProviderTypes
        open HSLocalStorage
        removeItemFromLocalStorage(~key="accept_invite_data")
        setAuthStatus(LoggedIn(BasicAuth(typedInfo)))
        setDashboardPageState(_ => #HOME)
      } else {
        showToast(~message="Failed to sign in, Try again", ~toastType=ToastError, ())
        handleLogout()->ignore
      }
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
