open APIUtils
// Common Hook is used to fetch order and refund details
let useOperationHook = () => {
  let fetchDetails = useGetMethod()

  async (orderId, url) => {
    try {
      if orderId->String.length !== 0 {
        await fetchDetails(url)
      } else {
        Exn.raiseError("OrderID Not Found")
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
        Exn.raiseError(err)
      }
    }
  }
}
