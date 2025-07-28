open APIUtils

let useFetchOrdersHook = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~payload) => {
    try {
      let ordersUrl = getURL(~entityName=V1(ORDERS), ~methodType=Post)
      let res = await updateDetails(ordersUrl, payload, Post)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
