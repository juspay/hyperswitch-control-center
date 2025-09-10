open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils

let defaultColumns: array<entryColType> = [
  EntryId,
  EntryType,
  TransactionId,
  Amount,
  Currency,
  Status,
  Metadata,
  CreatedAt,
  EffectiveAt,
]

let allColumns: array<entryColType> = [
  EntryId,
  EntryType,
  TransactionId,
  Amount,
  Currency,
  Status,
  Metadata,
  CreatedAt,
  EffectiveAt,
]

let getHeading = (colType: entryColType) => {
  switch colType {
  | EntryId => Table.makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | AccountName => Table.makeHeaderInfo(~key="account", ~title="Account")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Metadata => Table.makeHeaderInfo(~key="metadata", ~title="Metadata")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  }
}

let getStatusLabel = (statusString: string): Table.cell => {
  Table.Label({
    title: statusString->String.toUpperCase,
    color: switch statusString->String.toLowerCase {
    | "posted" => Table.LabelGreen
    | "mismatched" => Table.LabelRed
    | "expected" => Table.LabelBlue
    | "archived" => Table.LabelGray
    | "pending" => Table.LabelOrange
    | _ => Table.LabelLightGray
    },
  })
}

let getCell = (entry: entryPayload, colType: entryColType): Table.cell => {
  switch colType {
  | EntryId => Text(entry.entry_id)
  | EntryType => Text((entry.entry_type :> string))
  | AccountName => Text(entry.account_name)
  | TransactionId => Text(entry.transaction_id)
  | Amount => Text(Float.toString(entry.amount))
  | Currency => Text(entry.currency)
  | Status =>
    switch entry.discarded_status {
    | Some(discardedStatus) => getStatusLabel(discardedStatus)
    | None => getStatusLabel(entry.status)
    }
  | Metadata => Text(entry.metadata->JSON.stringify)
  | CreatedAt => Date(entry.created_at)
  | EffectiveAt => Date(entry.effective_at)
  }
}

let entriesEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getEntriesList,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="entries",
    ~getShowLink={
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.entry_id}`),
          ~authorization,
        )
      }
    },
  )
}
