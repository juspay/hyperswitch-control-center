open APIUtils
open PaymentListInterface
open LogicUtils

let rec jsonToQueryValue = value =>
  switch value->JSON.Classify.classify {
  | String(str) => str
  | Number(num) => num->Float.toString
  | Bool(bool) => bool->getStringFromBool
  | Array(arr) =>
    arr
    ->Array.map(jsonToQueryValue)
    ->Array.filter(value => value->isNonEmptyString)
    ->Array.joinWith(",")
  | _ => ""
  }

let payloadToQueryParameters = payload =>
  payload
  ->JSON.Decode.object
  ->Option.getOr(Dict.make())
  ->Dict.toArray
  ->Array.filterMap(item => {
    let (key, value) = item
    let queryValue = value->jsonToQueryValue
    queryValue->isNonEmptyString ? Some(`${key}=${queryValue->encodeURIComponent}`) : None
  })
  ->Array.joinWith("&")

let useFetchOrdersHook = () => {
  let getURL = useGetURL()
  let updateDetails = useCancellableUpdateMethod()
  let fetchDetails = useCancellableGetMethod()
  let {queryV2} = React.useContext(FilterContext.filterContext)

  async (~payload, ~version: UserInfoTypes.version, ~isPlatformMerchant=false, ~signal=?) => {
    try {
      switch version {
      | V1 => {
          let res = if isPlatformMerchant {
            let queryParameters = payload->payloadToQueryParameters
            let ordersUrl = getURL(
              ~entityName=V1(PLATFORM_ORDERS),
              ~methodType=Get,
              ~queryParameters=Some(queryParameters),
            )
            await fetchDetails(ordersUrl, ~signal?)
          } else {
            let ordersUrl = getURL(~entityName=V1(ORDERS), ~methodType=Post)
            await updateDetails(ordersUrl, payload, Post, ~signal?)
          }
          res->mapJsonToOrdersObject(paymentInterfaceV1)
        }
      | V2 => {
          let ordersUrl = getURL(
            ~entityName=V2(V2_ORDERS_LIST),
            ~methodType=Get,
            ~queryParameters=Some(queryV2),
          )
          let res = await fetchDetails(ordersUrl, ~signal?)
          res->mapJsonToOrdersObject(paymentInterfaceV2)
        }
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
