open LogicUtils
open ReconEngineUtils
open ReconEngineTransactionsTypes

let getArrayDictFromRes = res => {
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}

let formatAmountToString = (amount, ~currency) => {
  `${amount->Float.toString} ${currency}`
}

let getAmountPayload = dict => {
  {
    value: dict->getFloat("value", 0.0),
    currency: dict->getString("currency", ""),
  }
}

let getRulePayload = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
  }
}

let getAccountPayload = dict => {
  {
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
  }
}

let getTransactionsEntryPayload = dict => {
  {
    entry_id: dict->getString("entry_id", ""),
    entry_type: dict->getString("entry_type", ""),
    account: dict
    ->getDictfromDict("account")
    ->getAccountPayload,
  }
}

let getArrayOfTransactionsEntriesListPayloadType = json => {
  json->Array.map(entriesJson => {
    entriesJson->getDictFromJsonObject->getTransactionsEntryPayload
  })
}

let getHeadersForCSV = () => {
  "Order ID,Transaction ID,Payment Gateway,Payment Method,Txn Amount,Settlement Amount,Recon Status,Transaction Date"
}

let getAllTransactionPayload = (dict): transactionPayload => {
  {
    id: dict->getString("id", ""),
    transaction_id: dict->getString("transaction_id", ""),
    profile_id: dict->getString("profile_id", ""),
    entries: dict
    ->getArrayFromDict("entries", [])
    ->getArrayOfTransactionsEntriesListPayloadType,
    credit_amount: dict->getDictfromDict("credit_amount")->getAmountPayload,
    debit_amount: dict->getDictfromDict("debit_amount")->getAmountPayload,
    rule: dict->getDictfromDict("rule")->getRulePayload,
    transaction_status: dict->getString("transaction_status", ""),
    discarded_status: dict->getOptionString("discarded_status"),
    version: dict->getInt("version", 0),
    created_at: dict->getString("created_at", ""),
  }
}

let getArrayOfTransactionsListPayloadType = json => {
  json->Array.map(transactionJson => {
    transactionJson->getDictFromJsonObject->getAllTransactionPayload
  })
}

let getAllEntryPayload = dict => {
  {
    entry_id: dict->getString("entry_id", ""),
    entry_type: dict->getString("entry_type", ""),
    transaction_id: dict->getString("transaction_id", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", ""),
    discarded_status: dict->getOptionString("discarded_status"),
    metadata: dict->getJsonObjectFromDict("metadata"),
    created_at: dict->getString("created_at", ""),
    effective_at: dict->getString("effective_at", ""),
  }
}

let getArrayOfEntriesListPayloadType = json => {
  json->Array.map(entriesJson => {
    entriesJson->getDictFromJsonObject->getAllEntryPayload
  })
}

let getTransactionsList: JSON.t => array<transactionPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllTransactionPayload)
}

let getEntriesList: JSON.t => array<entryPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllEntryPayload)
}

let sortByVersion = (c1: transactionPayload, c2: transactionPayload) => {
  compareLogic(c1.version, c2.version)
}

let getAccounts = (entries: array<transactionEntryType>, entryType: string): string => {
  let accounts =
    entries
    ->Array.filter(entry => entry.entry_type === entryType)
    ->Array.map(entry => entry.account.account_name)

  let uniqueAccounts = accounts->Array.reduce([], (acc, accountName) => {
    if Array.includes(acc, accountName) {
      acc
    } else {
      Array.concat(acc, [accountName])
    }
  })

  uniqueAccounts->Array.joinWith(", ")
}

let getTransactionTypeFromString = (status: string): transactionStatus => {
  switch status {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | _ => UnknownTransactionStatus
  }
}

let getEntryTypeFromString = (entryType: string): entryStatus => {
  switch entryType {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | "pending" => Pending
  | _ => UnknownEntry
  }
}

let initialDisplayFilters = (~creditAccountOptions=[], ~debitAccountOptions=[], ()) => {
  let statusOptions = getTransactionStatusOptions([Mismatched, Expected, Posted])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="transaction_status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Transaction Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="credit_account",
          ~name="credit_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=creditAccountOptions,
            ~buttonText="Select Credit Account",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="debit_account",
          ~name="debit_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=debitAccountOptions,
            ~buttonText="Select Debit Account",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}

let getSampleStackedBarGraphData = () => {
  open StackedBarGraphTypes
  {
    categories: ["Total Orders"],
    data: [
      {
        name: "Expected",
        data: [400.0],
        color: "#8BC2F3",
      },
      {
        name: "Mismatch",
        data: [400.0],
        color: "#EA8A8F",
      },
      {
        name: "Matched",
        data: [1200.0],
        color: "#7AB891",
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}
