open Promise

@react.component
let make = (~viewType) => {
  let setViewType = Recoil.useSetRecoilState(HSwitchRecoilAtoms.viewType)
  let amountToShow =
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.amount)
    ->Belt.Float.fromString
    ->Belt.Option.getWithDefault(100.0) *. 100.0
  let amount = amountToShow->Belt.Int.fromFloat->Belt.Int.toString
  let fetchApi = AuthHooks.useApiFetcher()
  let (options, setOptions) = React.useState(_ => None)
  let (selectedMenu, setSelectedMenu) = React.useState(_ => "")

  let theme = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme)->Js.String2.toLowerCase
  let customerLocation = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.customerLocation)
  let currency = HSwitchSDKUtils.getCurrencyFromCustomerLocation(customerLocation)
  let country = HSwitchSDKUtils.getCountryFromCustomerLocation(customerLocation)
  let countryCode = country

  let hyperSwitchToken = LocalStorage.getItem("login")->Js.Nullable.toOption
  let fetchDetails = APIUtils.useGetMethod()
  let (merchantPublishableKey, setPublishableAPIKey) = React.useState(_ => "")

  let fetchMerchantInfo = async () => {
    try {
      let accountUrl = APIUtils.getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get, ())
      let merchantDetailsJSON = await fetchDetails(accountUrl)
      let merchantDetails = merchantDetailsJSON->HSwitchMerchantAccountUtils.getMerchantDetails
      setPublishableAPIKey(_ => merchantDetails.publishable_key)
    } catch {
    | Js.Exn.Error(e) =>
      let _err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
    }
  }

  React.useEffect0(() => {
    fetchMerchantInfo()->ignore
    setViewType(._ => viewType)
    None
  })

  React.useEffect1(() => {
    let body = HSwitchSDKUtils.getDefaultPayload(amount, currency, country, countryCode)

    let headers = switch hyperSwitchToken {
    | Some(key) =>
      switch key {
      | "" => [("Content-Type", "application/json"), ("api-key", HSwitchSDKUtils.defaultAPIKey)]
      | key => [
          ("Content-Type", "application/json"),
          ("Api-Key", "hyperswitch"),
          ("Authorization", `Bearer ${key}`),
        ]
      }
    | None => [("Content-Type", "application/json"), ("api-key", HSwitchSDKUtils.defaultAPIKey)]
    }

    fetchApi(
      HSwitchSDKUtils.backendEndpointUrl,
      ~method_=Fetch.Post,
      ~bodyStr=body->Js.Json.stringify,
      ~headers=headers->Js.Dict.fromArray,
      (),
    )
    ->then(resp => {
      Fetch.Response.json(resp)
    })
    ->then(json => {
      let clientSecret =
        json
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(x => x->Js.Dict.get("client_secret"))
        ->Belt.Option.flatMap(Js.Json.decodeString)
        ->Belt.Option.getWithDefault("")
      setOptions(_ => Some(HSwitchSDKUtils.getOptions(clientSecret, theme)))
      json->resolve
    })
    ->ignore
    None
  }, [theme])

  let hyperPromise = switch merchantPublishableKey {
  | "" => HSwitchSDKUtils.loadHyper(HSwitchSDKUtils.defaultPublishableKey)
  | key => HSwitchSDKUtils.loadHyper(key)
  }

  <div>
    {switch options {
    | Some(val) =>
      <HSwitchSDK
        options={val}
        selectedMenu={selectedMenu}
        customerPaymentMethods={[]}
        hyperPromise={hyperPromise}
      />
    | None => React.null
    }}
  </div>
}
