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
