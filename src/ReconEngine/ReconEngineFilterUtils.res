open LogicUtils
open ReconEngineTypes

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
  | Posted(Auto) => ("posted_auto", "Reconciled (Auto)", "Reconciled")
  | Posted(Manual) => ("posted_manual", "Reconciled (Manual)", "Reconciled")
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
  | PartiallyReconciled => ("partially_reconciled", "Partially Reconciled", "Others")
  | Missing => ("missing", "Missing", "Others")
  | Expected => ("expected", "Expected", "Others")
  | Void => ("void", "Void", "Others")
  | _ => ("", "", "")
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

let getTransactionStatusValueFromStatusList = (statusList: array<domainTransactionStatus>): array<
  string,
> => {
  statusList->Array.map(status => {
    let (value, _, _) = getTransactionStatusGroupedValueAndLabel(status)
    value
  })
}

let getMergedPostedTransactionStatusFilter = statusFilter => {
  if statusFilter->Array.some(v => v->getStringFromJson("") == "posted_manual") {
    if !(statusFilter->Array.some(v => v->getStringFromJson("") == "posted_force")) {
      [...statusFilter, "posted_force"->JSON.Encode.string]
    } else {
      statusFilter
    }
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
