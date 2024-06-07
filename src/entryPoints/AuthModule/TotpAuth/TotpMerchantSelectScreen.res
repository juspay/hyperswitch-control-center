@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let (merchantData, setMerchantData) = React.useState(_ => [])

  let getListOfMerchantIds = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#MERCHANTS_SELECT, ~methodType=Get, ())
      let listOfMerchants = await fetchDetails(url)
      setMerchantData(_ => listOfMerchants->getArrayFromJson([]))
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  React.useEffect0(() => {
    getListOfMerchantIds()->ignore
    None
  })

  let onClickLoginToDashboard = async () => {
    open TotpUtils
    try {
      let url = getURL(~entityName=USERS, ~userType=#ACCEPT_INVITE_TOKEN_ONLY, ~methodType=Post, ())

      let acceptedMerchantIds = merchantData->Array.reduce([], (acc, ele) => {
        let merchantDataDict = ele->getDictFromJsonObject
        if merchantDataDict->getBool("is_active", false) {
          acc->Array.push(merchantDataDict->getString("merchant_id", "")->JSON.Encode.string)
        }
        acc
      })
      let body = [("merchant_ids", acceptedMerchantIds->JSON.Encode.array)]->getJsonFromArrayOfJson
      let res = await updateDetails(url, body, Post, ())
      setAuthStatus(PreLogin(getPreLoginInfo(res)))
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
