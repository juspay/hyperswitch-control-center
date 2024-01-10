open APIUtils

let useGetRefundData = (refundId, setScreenState) => {
  let (refundData, setRefundData) = React.useState(() => Js.Json.null)
  let fetchDetails = useGetMethod()
  let accountUrl = getURL(~entityName=REFUNDS, ~methodType=Get, ~id=Some(refundId), ())

  let setLoadDataForRefunds = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if refundId->String.length !== 0 {
        let refundDataResponse = await fetchDetails(accountUrl)
        setRefundData(_ => refundDataResponse)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect1(() => {
    setLoadDataForRefunds()->ignore
    None
  }, [refundId])

  refundData
}
