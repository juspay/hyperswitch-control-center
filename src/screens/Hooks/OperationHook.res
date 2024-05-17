open APIUtils
// Common Hook is used to fetch order and refund details
let useOperationHook = () => {
  let fetchDetails = useGetMethod()

  async url => {
    try {
      await fetchDetails(url)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
        Exn.raiseError(err)
      }
    }
  }
}
