open APIUtils

let useFetchOrdersHook = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let {query} = React.useContext(FilterContext.filterContext)

  async (~payload, ~version: UserInfoTypes.version) => {
    try {
      let ordersUrl = switch version {
      | V1 => getURL(~entityName=V1(ORDERS), ~methodType=Post)
      | V2 => getURL(~entityName=V2(V2_ORDERS_LIST), ~methodType=Get, ~queryParamerters=Some(query))
      }
      let res = switch version {
      | V1 => await updateDetails(ordersUrl, payload, Post)
      | V2 => await fetchDetails(ordersUrl)
      }
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
