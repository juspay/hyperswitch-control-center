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
  | Posted(Auto) => ("posted_auto", "Posted Auto", "Posted")
  | Posted(Manual) => ("posted_manual", "Posted Manual", "Posted")
  | Posted(Force) => ("posted_force", "Posted Force", "Posted")
  | OverAmount(Expected) => ("over_amount_expected", "Over Amount Expected", "Over Amount")
  | OverAmount(Mismatch) => ("over_amount_mismatch", "Over Amount Mismatch", "Over Amount")
  | UnderAmount(Expected) => ("under_amount_expected", "Under Amount Expected", "Under Amount")
  | UnderAmount(Mismatch) => ("under_amount_mismatch", "Under Amount Mismatch", "Under Amount")
  | DataMismatch => ("data_mismatch", "Data Mismatch", "Others")
  | Expected => ("expected", "Expected", "Others")
  | Void => ("void", "Void", "Others")
  | PartiallyReconciled => ("partially_reconciled", "Partially Reconciled", "Others")
  | _ => ("", "", "")
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
    let value: string = (status :> string)->camelToSnake
    let label = (status :> string)->camelCaseToTitle

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
