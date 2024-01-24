open APIUtils
let useListCount = (~entityName) => {
  open ConnectorUtils
  let fetchDetails = useGetMethod()
  let (count, setCount) = React.useState(() => 0)

  let fetchData = async () => {
    open LogicUtils
    let getUrl = getURL(~entityName, ~methodType=Get, ())
    try {
      let response = await fetchDetails(getUrl)
      let count = switch entityName {
      | ROUTING => response->getDictFromJsonObject->getArrayFromDict("records", [])->Array.length
      | CONNECTOR =>
        response->getObjectArrayFromJson->filterList(~removeFromList=FRMPlayer)->Array.length
      | FRAUD_RISK_MANAGEMENT =>
        response->getObjectArrayFromJson->filterList(~removeFromList=Connector)->Array.length
      | _ => response->getArrayFromJson([])->Array.length
      }
      setCount(_ => count)
    } catch {
    | _ => setCount(_ => 0)
    }
  }

  React.useEffect0(() => {
    HSLocalStorage.getFromMerchantDetails("merchant_id")->String.length > 0
      ? fetchData()->ignore
      : ()
    None
  })

  count
}
