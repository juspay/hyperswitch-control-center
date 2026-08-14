open LogicUtils
open ReconEngineTypes
open ReconEngineFilterTypes
open HSAnalyticsUtils

let globalDateFilterContextIndex = "recon-engine-global-date"
let globalDateFilterKeys = [startTimeFilterKey, endTimeFilterKey]

let globalDateFilterPortalName = "reconGlobalDateFilter"

let getGlobalDateFilterFromDict = (dict: Dict.t<string>): globalDateFilter => {
  startTime: dict->getValueFromDict(startTimeFilterKey, ""),
  endTime: dict->getValueFromDict(endTimeFilterKey, ""),
}

let mergeGlobalDateFilters = (
  ~filterValueJson: Dict.t<JSON.t>,
  ~globalDateFilters: globalDateFilter,
) => {
  let dateEntries =
    [
      (startTimeFilterKey, globalDateFilters.startTime),
      (endTimeFilterKey, globalDateFilters.endTime),
    ]
    ->Array.filter(((_, value)) => value->isNonEmptyString)
    ->Array.map(((key, value)) => (key, value->UrlFetchUtils.getFilterValue))

  Array.concat(filterValueJson->Dict.toArray, dateEntries)->Dict.fromArray
}

let hasGlobalDateFilterValue = (~globalDateFilters: globalDateFilter) =>
  globalDateFilters.startTime->isNonEmptyString && globalDateFilters.endTime->isNonEmptyString

let getAccountOptionsFromTransactions = (
  transactions: array<transactionType>,
  entryType: entryDirectionType,
): array<FilterSelectBox.dropdownOption> => {
  let allAccounts =
    transactions
    ->Array.flatMap(transaction => transaction.entries)
    ->Array.filter(entry => entry.entry_type === entryType)
    ->Array.map(entry => entry.account)

  let uniqueAccounts = allAccounts->Array.reduce([], (acc: array<accountType>, account) => {
    let exists =
      acc->Array.some(existingAccount => existingAccount.account_id === account.account_id)
    if exists {
      acc
    } else {
      Array.concat(acc, [account])
    }
  })

  uniqueAccounts->Array.map(account => {
    {
      FilterSelectBox.label: account.account_name,
      value: account.account_id,
    }
  })
}

let getEntryTypeAccountOptions = (
  transactions: array<transactionType>,
  ~entryType: entryDirectionType,
): array<FilterSelectBox.dropdownOption> => {
  getAccountOptionsFromTransactions(transactions, entryType)
}

let refreshEndTimeFilter = updateExistingKeys => {
  updateExistingKeys(
    Dict.fromArray([(endTimeFilterKey, HSwitchRemoteFilter.getDateFilteredObject().end_time)]),
  )
}

let toReconTimeString = value =>
  value->isNonEmptyString ? value->dateFormat("YYYY-MM-DDTHH:mm:ss[Z]") : value

let buildQueryStringFromFilters = (~filterValueJson: Dict.t<JSON.t>, ~convertToLocal=true) => {
  let queryParts = []
  let formatTime = convertToLocal ? toReconTimeString : v => v

  filterValueJson
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    let (apiKey, formatValue) = switch key {
    | "startTime" => ("start_time", formatTime)
    | "endTime" => ("end_time", formatTime)
    | _ => (key, v => v)
    }

    switch value->JSON.Classify.classify {
    | String(str) =>
      if str->isNonEmptyString {
        queryParts->Array.push(`${apiKey}=${str->formatValue}`)
      }
    | Number(num) => queryParts->Array.push(`${apiKey}=${num->Float.toString}`)
    | Array(arr) => {
        let arrayValues = arr->Array.map(item => item->getStringFromJson(""))->Array.joinWith(",")
        if arrayValues->isNonEmptyString {
          queryParts->Array.push(`${apiKey}=${arrayValues}`)
        }
      }
    | Bool(bool) => queryParts->Array.push(`${apiKey}=${bool->getStringFromBool}`)
    | _ => ()
    }
  })

  queryParts->Array.joinWith("&")
}

let getTransactionStatusGroupedValueAndLabel = (status: domainTransactionStatus): (
  string,
  string,
  string,
) => {
  switch status {
  | Posted(Manual) => ("posted_manual", "Posted (Manual)", "Posted")
  | Matched(Auto) => ("matched_auto", "Matched (Auto)", "Matched")
  | Matched(Manual) => ("matched_manual", "Matched (Manual)", "Matched")
  | OverAmount(Expected) => (
      "over_amount_expected",
      "Positive Variance (Awaiting Match)",
      "Positive Variance",
    )
  | OverAmount(Mismatch) => (
      "over_amount_mismatch",
      "Positive Variance (Requires Attention)",
      "Positive Variance",
    )
  | UnderAmount(Expected) => (
      "under_amount_expected",
      "Negative Variance (Awaiting Match)",
      "Negative Variance",
    )
  | UnderAmount(Mismatch) => (
      "under_amount_mismatch",
      "Negative Variance (Requires Attention)",
      "Negative Variance",
    )
  | DataMismatch => ("data_mismatch", "Data Mismatch", "Others")
  | PartiallyReconciled => ("partially_reconciled", "Partially Matched", "Others")
  | Missing => ("missing", "Missing", "Others")
  | Expected => ("expected", "Expected", "Others")
  | Void => ("void", "Void", "Others")
  | Matched(Force) => ("matched_force", "", "")
  | Matched(WithTolerance) => ("matched_with_tolerance", "Matched (With Tolerance)", "Matched")
  | CurrencyMismatch => ("currency_mismatch", "Currency Mismatch", "Others")
  | SplitMismatch => ("split_mismatch", "Split Mismatch", "Others")
  | Archived
  | Matched(UnknownDomainTransactionMatchedStatus)
  | Posted(UnknownDomainTransactionPostedStatus)
  | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
  | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
  | UnknownDomainTransactionStatus => ("", "", "")
  }
}

let getProcessingEntryStatusValueAndLabel = (status: processingEntryStatus): (string, string) => {
  let value: string = (status :> string)->camelToSnake
  let label = (status :> string)->snakeToTitle
  (value, label)
}

let getProcessingEntryStatusValueFromStatusList = (statusList: array<processingEntryStatus>): array<
  string,
> => {
  statusList->Array.map(status => {
    let (value, _) = getProcessingEntryStatusValueAndLabel(status)
    value
  })
}

let getIngestionTransformationHistoryStatusValueFromStatusList = (
  statusList: array<ingestionTransformationStatusType>,
): array<string> => {
  statusList->Array.map(status => (status :> string)->camelToSnake)
}

let getTransactionStatusValueFromStatusList = (statusList: array<domainTransactionStatus>): array<
  string,
> => {
  statusList->Array.map(status => {
    let (value, _, _) = getTransactionStatusGroupedValueAndLabel(status)
    value
  })
}

let getMergedMatchedTransactionStatusFilter = statusFilter => {
  let (matchedManualValue, _, _) = getTransactionStatusGroupedValueAndLabel(Matched(Manual))
  let (matchedForceValue, _, _) = getTransactionStatusGroupedValueAndLabel(Matched(Force))

  let hasStatus = value => statusFilter->Array.some(v => v->getStringFromJson("") == value)
  if hasStatus(matchedManualValue) && !hasStatus(matchedForceValue) {
    [...statusFilter, matchedForceValue->JSON.Encode.string]
  } else {
    statusFilter
  }
}

let getGroupedTransactionStatusOptions = (statusList: array<domainTransactionStatus>): array<
  FilterSelectBox.dropdownOption,
> => {
  statusList->Array.map(status => {
    let (value, label, optGroup) = getTransactionStatusGroupedValueAndLabel(status)

    {
      FilterSelectBox.label,
      value,
      optGroup,
    }
  })
}

let getStagingEntryStatusOptions = (statusList: array<processingEntryStatus>): array<
  FilterSelectBox.dropdownOption,
> => {
  statusList->Array.map(status => {
    let (value, label) = getProcessingEntryStatusValueAndLabel(status)

    {
      FilterSelectBox.label,
      value,
    }
  })
}

let getAccountOptionsFromStagingEntries = (stagingData: array<processingEntryType>) => {
  let allAccounts = stagingData->Array.map(entry => entry.account)

  let uniqueAccounts = allAccounts->Array.reduce([], (acc: array<accountRefType>, account) => {
    let exists =
      acc->Array.some(existingAccount => existingAccount.account_id === account.account_id)
    exists ? acc : [...acc, account]
  })

  uniqueAccounts->Array.map(account => {
    {
      FilterSelectBox.label: account.account_name,
      value: account.account_id,
    }
  })
}
