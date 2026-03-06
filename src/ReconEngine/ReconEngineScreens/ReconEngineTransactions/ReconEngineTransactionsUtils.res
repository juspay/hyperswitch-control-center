open LogicUtils
open ReconEngineFilterUtils
open ReconEngineTypes
open ReconEngineTransactionsTypes
open ReconEngineUtils

let entriesMetadataKeyToString = key => {
  switch key {
  | Amount => "amount"
  | Currency => "currency"
  }
}

let entriesMetadataExcludedKeys = [Amount, Currency]->Array.map(entriesMetadataKeyToString)

let getFilteredMetadataFromEntries = metadata => {
  metadata
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.filter(((key, _value)) => {
    !Array.includes(entriesMetadataExcludedKeys, key)
  })
  ->Dict.fromArray
}

let getHeadersForCSV = () => {
  "Order ID,Transaction ID,Payment Gateway,Payment Method,Txn Amount,Settlement Amount,Recon Status,Transaction Date"
}

let getTransactionsPayloadFromDict = dict => {
  dict->transactionItemToObjMapper
}

let transactionsEntryItemToObjMapperFromDict = dict => {
  dict->entryItemToObjMapper
}

let sortByVersion = (c1: transactionType, c2: transactionType) => {
  compareLogic(c1.version, c2.version)
}

let getAccounts = (entries: array<transactionEntryType>, entryType: entryDirectionType): string => {
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

let initialDisplayFilters = (~creditAccountOptions=[], ~debitAccountOptions=[], ()) => {
  let statusOptions = getGroupedTransactionStatusOptions([
    Posted(Auto),
    Posted(Manual),
    OverAmount(Mismatch),
    OverAmount(Expected),
    UnderAmount(Mismatch),
    UnderAmount(Expected),
    DataMismatch,
    PartiallyReconciled,
    Expected,
    Missing,
    Void,
  ])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="status",
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
          ~label="source_account",
          ~name="source_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=creditAccountOptions,
            ~buttonText="Select Source Account",
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
          ~label="target_account",
          ~name="target_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=debitAccountOptions,
            ~buttonText="Select Target Account",
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

let getTransactionStatusLabelColor = (status: domainTransactionStatus): TableUtils.labelColor => {
  switch status {
  | Posted(_) => LabelGreen
  | OverAmount(Mismatch)
  | UnderAmount(Mismatch)
  | DataMismatch =>
    LabelRed
  | Expected | UnderAmount(Expected) | OverAmount(Expected) => LabelBlue
  | Archived => LabelGray
  | PartiallyReconciled | Missing => LabelOrange
  | Void | UnknownDomainTransactionStatus => LabelLightGray
  }
}
