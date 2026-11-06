open APIUtils
open LogicUtils
open ExplorerTypes

let useFetchExplorerMetrics = () => {
  let getURL = useGetURL()
  let updateDetails = useCancellableUpdateMethod(~showErrorToast=false)

  async (~source: source, ~body, ~signal) => {
    let entityName: APIUtilsTypes.entityName = switch source {
    | #intent => ANALYTICS_PAYMENTS_V2
    | #attempt => ANALYTICS_PAYMENTS
    | #refund => ANALYTICS_REFUNDS
    | #dispute => ANALYTICS_DISPUTES
    }
    let url = getURL(
      ~entityName=V1(entityName),
      ~methodType=Post,
      ~id=Some((ExplorerCatalog.sourceConfig(source).domain :> string)),
    )
    let response = await updateDetails(url, body, Post, ~signal)
    response->getDictFromJsonObject->getArrayFromDict("queryData", [])
  }
}

let useFetchBackendDimensions = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)

  async (~infoDomain) => {
    let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Get, ~id=Some(infoDomain))
    let response = await fetchDetails(url)
    response
    ->getDictFromJsonObject
    ->getArrayFromDict("dimensions", [])
    ->Array.map(item => item->getDictFromJsonObject->getString("name", ""))
    ->Array.filter(isNonEmptyString)
  }
}

let useFetchFilterValues = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async (~selection, ~dimension) => {
    let domain = ExplorerCatalog.sourceConfig(selection.source).domain
    let url = getURL(
      ~entityName=V1(ANALYTICS_FILTERS),
      ~methodType=Post,
      ~id=Some((domain :> string)),
    )
    let response = await updateDetails(
      url,
      selection->ExplorerSelection.getFilterValuesBody(~dimension),
      Post,
    )
    response
    ->getDictFromJsonObject
    ->getArrayFromDict("queryData", [])
    ->Array.flatMap(item => item->getDictFromJsonObject->getStrArrayFromDict("values", []))
    ->Array.filter(isNonEmptyString)
  }
}
