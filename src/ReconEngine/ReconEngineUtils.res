open LogicUtils
open ReconEngineTransactionsTypes

let getAccountOptionsFromTransactions = (
  transactions: array<transactionPayload>,
  entryType: string,
): array<FilterSelectBox.dropdownOption> => {
  let allAccounts =
    transactions
    ->Array.flatMap(transaction => transaction.entries)
    ->Array.filter(entry => entry.entry_type === entryType)
    ->Array.map(entry => entry.account)

  let uniqueAccounts = allAccounts->Array.reduce([], (acc, account) => {
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

let getCreditAccountOptions = (transactions: array<transactionPayload>): array<
  FilterSelectBox.dropdownOption,
> => {
  getAccountOptionsFromTransactions(transactions, "credit")
}

let getDebitAccountOptions = (transactions: array<transactionPayload>): array<
  FilterSelectBox.dropdownOption,
> => {
  getAccountOptionsFromTransactions(transactions, "debit")
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

let getTransactionStatusOptions = (statusList: array<transactionStatus>): array<
  FilterSelectBox.dropdownOption,
> => {
  statusList->Array.map(status => {
    let value: string = (status :> string)->String.toLowerCase
    let label = (status :> string)->capitalizeString
    {
      FilterSelectBox.label,
      value,
    }
  })
}
