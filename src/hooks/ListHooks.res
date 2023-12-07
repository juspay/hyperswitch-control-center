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
      | ROUTING =>
        response->getDictFromJsonObject->getArrayFromDict("records", [])->Js.Array2.length
      | CONNECTOR =>
        response
        ->getObjectArrayFromJson
        ->HSwitchUtils.filterList(~removeFromList=FRMPlayer)
        ->Js.Array2.length
      | FRAUD_RISK_MANAGEMENT =>
        response
        ->getObjectArrayFromJson
        ->HSwitchUtils.filterList(~removeFromList=Connector)
        ->Js.Array2.length
      | _ => response->getArrayFromJson([])->Js.Array2.length
      }
      setCount(_ => count)
    } catch {
    | _ => setCount(_ => 0)
    }
  }

  React.useEffect0(() => {
    HSLocalStorage.getFromMerchantDetails("merchant_id")->Js.String2.length > 0
      ? fetchData()->ignore
      : ()
    None
  })

  count
}
