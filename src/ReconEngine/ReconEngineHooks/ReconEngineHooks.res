let useGetIngestionHistory = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineUtils

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

let useGetTransactions = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineTransactionsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParamerters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~queryParamerters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(getAllTransactionPayload)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
