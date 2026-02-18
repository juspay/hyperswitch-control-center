open APIUtils
open PaymentListInterface

let useFetchAnalyticsOrdersHook = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let {queryV2} = React.useContext(FilterContext.filterContext)

  async (~payload, ~version: UserInfoTypes.version) => {
    try {
      let paymentsData = switch version {
      | V1 => {
          try {
            let ordersUrl = getURL(~entityName=V1(PAYMENTS_LIST), ~methodType=Post)
            let res = await updateDetails(ordersUrl, payload, Post)
            let mappedRes = res->mapAnalyticsResponseToOrdersObject
            mappedRes
          } catch {
          | Exn.Error(_e) => {
              let ordersUrl = getURL(~entityName=V1(ORDERS), ~methodType=Post)
              let res = await updateDetails(ordersUrl, payload, Post)
              res->mapJsonToOrdersObject(paymentInterfaceV1)
            }
          | _ => {
              let ordersUrl = getURL(~entityName=V1(ORDERS), ~methodType=Post)
              let res = await updateDetails(ordersUrl, payload, Post)
              res->mapJsonToOrdersObject(paymentInterfaceV1)
            }
          }
        }
      | V2 => {
          let ordersUrl = getURL(
            ~entityName=V2(V2_ORDERS_LIST),
            ~methodType=Get,
            ~queryParameters=Some(queryV2),
          )
          let res = await fetchDetails(ordersUrl)
          res->mapJsonToOrdersObject(paymentInterfaceV2)
        }
      }

      paymentsData
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
