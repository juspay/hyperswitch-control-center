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

let buildQueryStringFromFilters = (~filterValueJson: Dict.t<JSON.t>) => {
  let queryParts = []

  filterValueJson
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    let apiKey = switch key {
    | "startTime" => "start_time"
    | "endTime" => "end_time"
    | _ => key
    }

    switch value->JSON.Classify.classify {
    | String(str) =>
      if str->isNonEmptyString {
        queryParts->Array.push(`${apiKey}=${str}`)
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

let stagingEntryManualReviewReasons: array<stagingEntryManualReviewData> = [
  NoRulesFound,
  CurrencyMismatch,
  MissingSearchIdentifierValue,
  DuplicateEntry,
  NoExpectationEntryFound,
  MultipleExpectedEntriesFound,
  MissingMatchField,
  MissingUniqueField,
  MissingGroupingField,
  InternalError,
]

let stagingEntryStatusOptGroup = "Entry Status"
let manualReviewOptGroup = "Needs Manual Review"

let getStagingEntryDetailedStatusGroupedValueAndLabel = (status: domainStagingEntryStatus): (
  string,
  string,
  string,
) => {
  switch status {
  | Pending => ("pending", "Pending", stagingEntryStatusOptGroup)
  | Processed => ("processed", "Processed", stagingEntryStatusOptGroup)
  | Void => ("void", "Void", stagingEntryStatusOptGroup)
  | Archived => ("archived", "Archived", stagingEntryStatusOptGroup)
  | NeedsManualReview(UnknownStagingEntryManualReviewData) => (
      "needs_manual_review",
      "Needs Manual Review",
      stagingEntryStatusOptGroup,
    )
  | NeedsManualReview(reason) => {
      let reasonValue = (reason :> string)
      (`needs_manual_review_${reasonValue}`, reasonValue->snakeToTitle, manualReviewOptGroup)
    }
  | UnknownDomainStagingEntryStatus => ("", "", "")
  }
}

let stagingEntryDetailedStatusFilterOptions: array<domainStagingEntryStatus> = Array.concat(
  [Pending, Processed, Void],
  stagingEntryManualReviewReasons->Array.map(reason => NeedsManualReview(reason)),
)

let stagingEntryDetailedStatuses: array<domainStagingEntryStatus> = Array.concat(
  [NeedsManualReview(UnknownStagingEntryManualReviewData)],
  stagingEntryDetailedStatusFilterOptions,
)

let getStagingEntryDetailedStatusFromValue = (value: string): domainStagingEntryStatus =>
  stagingEntryDetailedStatuses
  ->Array.find(status => {
    let (statusValue, _, _) = getStagingEntryDetailedStatusGroupedValueAndLabel(status)
    statusValue === value
  })
  ->Option.getOr(UnknownDomainStagingEntryStatus)

let encodeStagingEntryDetailedStatus = (status: domainStagingEntryStatus): option<JSON.t> => {
  let encode = (coarseStatus, subStatus) => {
    let fields = [("status", coarseStatus->JSON.Encode.string)]
    switch subStatus {
    | Some(sub) => fields->Array.push(("sub_status", sub->JSON.Encode.string))
    | None => ()
    }
    Some(fields->getJsonFromArrayOfJson)
  }

  switch status {
  | Pending => encode("pending", None)
  | Processed => encode("processed", None)
  | Void => encode("void", None)
  | Archived => encode("archived", None)
  | NeedsManualReview(UnknownStagingEntryManualReviewData) => encode("needs_manual_review", None)
  | NeedsManualReview(reason) => encode("needs_manual_review", Some((reason :> string)))
  | UnknownDomainStagingEntryStatus => None
  }
}

let getStagingEntryDetailedStatusPayload = (statusList: array<domainStagingEntryStatus>): JSON.t =>
  statusList->Array.filterMap(encodeStagingEntryDetailedStatus)->JSON.Encode.array

let getGroupedStagingEntryDetailedStatusOptions = (
  statusList: array<domainStagingEntryStatus>,
): array<FilterSelectBox.dropdownOption> => {
  statusList->Array.map(status => {
    let (value, label, optGroup) = getStagingEntryDetailedStatusGroupedValueAndLabel(status)

    {
      FilterSelectBox.label,
      value,
      optGroup,
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
