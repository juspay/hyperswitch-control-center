open APIUtils
open PaymentListInterface

let useFetchAnalyticsOrdersHook = () => {
  let getURL = useGetURL()
  let updateDetails = useCancellableUpdateMethod()
  let fetchDetails = useCancellableGetMethod()
  let {queryV2} = React.useContext(FilterContext.filterContext)

  async (~payload, ~version: UserInfoTypes.version, ~isPlatformMerchant=false, ~signal=?) => {
    try {
      switch version {
      | V1 =>
        if isPlatformMerchant {
          let queryParameters = payload->OrdersHook.payloadToQueryParameters
          let url = getURL(
            ~entityName=V1(PLATFORM_ORDERS),
            ~methodType=Get,
            ~queryParameters=Some(queryParameters),
          )
          let res = await fetchDetails(url, ~signal?)
          res->mapJsonToOrdersObject(paymentInterfaceV1)
        } else {
          try {
            let url = getURL(~entityName=V1(PAYMENTS_LIST), ~methodType=Post)
            let res = await updateDetails(url, payload, Post, ~signal?)
            res->mapAnalyticsResponseToOrdersObject
          } catch {
          | AbortControllerHook.AbortError => raise(AbortControllerHook.AbortError)
          | _ if signal->Option.mapOr(false, AbortControllerHook.isAborted) =>
            raise(AbortControllerHook.AbortError)
          | _ => {
              let url = getURL(~entityName=V1(ORDERS), ~methodType=Post)
              let res = await updateDetails(url, payload, Post, ~signal?)
              res->mapJsonToOrdersObject(paymentInterfaceV1)
            }
          }
        }
      | V2 => {
          let url = getURL(
            ~entityName=V2(V2_ORDERS_LIST),
            ~methodType=Get,
            ~queryParameters=Some(queryV2),
          )
          let res = await fetchDetails(url, ~signal?)
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
