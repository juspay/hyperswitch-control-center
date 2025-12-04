open ReconEngineUtils

let useGetIngestionHistory = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      let ingestionHistory = res->getArrayDataFromJson(ingestionHistoryItemToObjMapper)
      ingestionHistory->Array.sort((a, b) => compareLogic(b.created_at, a.created_at))
      ingestionHistory
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetTransactions = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      let transactions = res->getArrayDataFromJson(transactionItemToObjMapper)
      transactions->Array.sort((a, b) => compareLogic(b.effective_at, a.effective_at))
      transactions
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetAccounts = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      let accounts = res->getArrayDataFromJson(accountItemToObjMapper)
      accounts->Array.sort((a, b) => compareLogic(b.created_at, a.created_at))
      accounts
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetProcessingEntries = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      let processedEntries = res->getArrayDataFromJson(processingItemToObjMapper)
      processedEntries->Array.sort((a, b) => compareLogic(b.effective_at, a.effective_at))
      processedEntries
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetTransformationHistory = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      let transformationHistory = res->getArrayDataFromJson(transformationHistoryItemToObjMapper)
      transformationHistory->Array.sort((a, b) => compareLogic(b.created_at, a.created_at))
      transformationHistory
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
