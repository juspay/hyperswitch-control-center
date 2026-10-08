open APIUtils
open LogicUtils
open ExplorerTypes

let useFetchExplorerMetrics = () => {
  let getURL = useGetURL()
  let updateDetails = useCancellableUpdateMethod(~showErrorToast=false)

  async (~source, ~body, ~signal) => {
    try {
      let url = switch source {
      | Intent =>
        getURL(~entityName=V1(ANALYTICS_PAYMENTS_V2), ~methodType=Post, ~id=Some("payments"))
      | Attempt =>
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

let useFetchBackendDimensions = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)

  async (~infoDomain) => {
    try {
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Get, ~id=Some(infoDomain))
      let response = await fetchDetails(url)
      response
      ->getDictFromJsonObject
      ->getArrayFromDict("dimensions", [])
      ->Array.map(item => item->getDictFromJsonObject->getString("name", ""))
      ->Array.filter(isNonEmptyString)
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch dimensions"))
    }
  }
}

let useFetchFilterValues = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~question, ~dimension) => {
    try {
      let url = getURL(~entityName=V1(ANALYTICS_FILTERS), ~methodType=Post, ~id=Some("payments"))
      let response = await updateDetails(
        url,
        question->ExplorerQuery.getFilterValuesBody(~dimension),
        Post,
      )
      response
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.flatMap(item => item->getDictFromJsonObject->getStrArrayFromDict("values", []))
      ->Array.filter(isNonEmptyString)
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch filter values"))
    }
  }
}
