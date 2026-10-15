open APIUtils
open LogicUtils
open ExplorerTypes

let useFetchExplorerMetrics = () => {
  let getURL = useGetURL()
  let updateDetails = useCancellableUpdateMethod(~showErrorToast=false)

  async (~source: source, ~body, ~signal) => {
    try {
      let url = switch source {
      | #intent =>
        getURL(~entityName=V1(ANALYTICS_PAYMENTS_V2), ~methodType=Post, ~id=Some("payments"))
      | #attempt =>
        getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some("payments"))
      }
      let response = await updateDetails(url, body, Post, ~signal)
      response->getDictFromJsonObject->getArrayFromDict("queryData", [])
    } catch {
    | Exn.Error(e) =>
      Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch explorer metrics"))
    }
  }
}
