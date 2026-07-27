open APIUtils
open LogicUtils

let useGetConnectorWebhooks = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  async mcaId => {
    try {
      let url = getURL(~entityName=V1(CONNECTOR_WEBHOOK), ~methodType=Get, ~id=Some(mcaId))
      let res = await fetchDetails(url)
      res->getDictFromJsonObject->getArrayFromDict("webhooks", [])
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
