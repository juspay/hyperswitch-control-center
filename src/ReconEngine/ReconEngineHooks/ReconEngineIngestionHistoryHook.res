let useGetIngestionHistory = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineFileManagementUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParamerters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~queryParamerters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(ingestionHistoryItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
