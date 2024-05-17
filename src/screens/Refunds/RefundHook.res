open APIUtils

let useGetRefundData = () => {
  let fetchDetails = useGetMethod()

  async (refundId, url) => {
    try {
      if refundId->String.length !== 0 {
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
