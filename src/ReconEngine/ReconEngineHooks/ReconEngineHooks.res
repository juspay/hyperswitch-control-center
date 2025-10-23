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
  open ReconEngineUtils

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
      res->getArrayDataFromJson(transactionItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetAccounts = () => {
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
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~queryParamerters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(accountItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetProcessingEntries = () => {
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
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~queryParamerters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(processingItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetTransformationHistory = () => {
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
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(transformationHistoryItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
