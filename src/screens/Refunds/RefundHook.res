open APIUtils

let useGetRefundData = (refundId, setScreenState) => {
  let (refundData, setRefundData) = React.useState(() => JSON.Encode.null)
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
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect1(() => {
    setLoadDataForRefunds()->ignore
    None
  }, [refundId])

  refundData
}
