open ReconEngineUtils
open APIUtils
open LogicUtils

let useGetIngestionHistory = () => {
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
      ingestionHistory->Array.sort((a, b) => compareLogic(a.created_at, b.created_at))
      ingestionHistory
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetTransactions = () => {
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
      transactions->Array.sort((a, b) => compareLogic(b.created_at, a.created_at))
      transactions
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetCursorPage = (
  ~hyperswitchReconType: APIUtilsTypes.hyperswitchReconType,
  ~itemMapper: Dict.t<JSON.t> => 'item,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~body: JSON.t): ReconEngineTypes.cursorPage<'item> => {
    try {
      let url = getURL(~entityName=V1(HYPERSWITCH_RECON), ~methodType=Post, ~hyperswitchReconType)
      let res = await updateDetails(url, body, Post)
      let dict = res->getDictFromJsonObject
      {
        items: dict->getArrayFromDict("items", [])->getMappedValueFromArrayOfJson(itemMapper),
        cursors: dict->cursorsFromDict,
      }
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetAccounts = () => {
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

let useGetIngestionConfigs = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(ingestionConfigItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetReconRuleList = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#RECON_RULES,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(ReconEngineRulesUtils.ruleItemToObjMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetOverviewRules = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#OVERVIEW_RULES,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(overviewRulesResponseMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetRuleAccountBreakdown = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#RULE_ACCOUNT_BREAKDOWN,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(ruleAccountsOverviewMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetStagingEntriesOverview = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#STAGING_ENTRIES_OVERVIEW,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(accountStagingEntriesOverviewMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetOverviewRulesTimeSeries = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~queryParameters=None) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#OVERVIEW_RULES_TIME_SERIES,
        ~queryParameters,
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(overviewRulesTimeSeriesResponseMapper)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useGetProcessingEntries = () => {
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

let useFetchMetadataSchema = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async (~transformationId: string) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG_WITH_METADATA,
        ~id=Some(transformationId),
      )
      await fetchDetails(url)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
