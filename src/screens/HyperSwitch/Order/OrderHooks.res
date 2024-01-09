open APIUtils

let useGetOrdersData = (orderId, refetchCounter, setScreenState) => {
  let (orderData, setOrderData) = React.useState(() => Js.Json.null)
  let fetchDetails = useGetMethod()
  let accountUrl = getURL(
    ~entityName=ORDERS,
    ~methodType=Get,
    ~id=Some(orderId),
    ~queryParamerters=Some("expand_attempts=true"),
    (),
  )
  let showToast = ToastState.useShowToast()
  let setLoadDataForOrders = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if orderId->String.length !== 0 {
        let orderDataResponse = await fetchDetails(accountUrl)
        setOrderData(_ => orderDataResponse)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | Js.Exn.Error(e) =>
      switch Js.Exn.message(e) {
      | Some(message) =>
        if message->String.includes("HE_02") {
          setScreenState(_ => Custom)
        } else {
          showToast(~message="Failed to Fetch!", ~toastType=ToastState.ToastError, ())
          setScreenState(_ => Error("Failed to Fetch!"))
        }

      | None => setScreenState(_ => Error("Failed to Fetch!"))
      }
    }
  }

  React.useEffect2(() => {
    if orderId->String.length !== 0 {
      setLoadDataForOrders()->ignore
    }
    None
  }, (orderId, refetchCounter))

  orderData
}
