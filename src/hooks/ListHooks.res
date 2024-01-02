open APIUtils
let useListCount = (~entityName) => {
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
        response
        ->getObjectArrayFromJson
        ->HSwitchUtils.filterList(~removeFromList=FRMPlayer)
        ->Array.length
      | FRAUD_RISK_MANAGEMENT =>
        response
        ->getObjectArrayFromJson
        ->HSwitchUtils.filterList(~removeFromList=Connector)
        ->Array.length
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
