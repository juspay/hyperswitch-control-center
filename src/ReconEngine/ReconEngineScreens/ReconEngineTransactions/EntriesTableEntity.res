open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils
open ReconEngineUtils

let defaultColumns: array<entryColType> = [
  EntryId,
  EntryType,
  TransactionId,
  Amount,
  Currency,
  Status,
  DiscardedStatus,
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
  DiscardedStatus,
  Metadata,
  CreatedAt,
  EffectiveAt,
]

let getHeading = (colType: entryColType) => {
  switch colType {
  | EntryId => Table.makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | DiscardedStatus => Table.makeHeaderInfo(~key="discarded_status", ~title="Discarded Status")
  | Metadata => Table.makeHeaderInfo(~key="metadata", ~title="Metadata")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  }
}

let getCell = (entry: entryPayload, colType: entryColType): Table.cell => {
  switch colType {
  | EntryId => Text(entry.entry_id)
  | EntryType => Text(entry.entry_type)
  | TransactionId => Text(entry.transaction_id)
  | Amount => Text(Float.toString(entry.amount))
  | Currency => Text(entry.currency)
  | Status =>
    Label({
      title: {entry.status->getDisplayStatusName},
      color: switch entry.status->String.toLowerCase {
      | "posted" => LabelGreen
      | "mismatched" => LabelRed
      | "expected" => LabelBlue
      | "archived" => LabelGray
      | "pending" => LabelOrange
      | _ => LabelGray
      },
    })
  | DiscardedStatus =>
    Label({
      title: {entry.discarded_status->getDisplayStatusName},
      color: switch entry.discarded_status->String.toLowerCase {
      | "posted" => LabelGreen
      | "mismatched" => LabelRed
      | "expected" => LabelBlue
      | "archived" => LabelGray
      | "pending" => LabelOrange
      | _ => LabelGray
      },
    })
  | Metadata => CustomCell(<div> {"Here is the metadata: "->React.string} </div>, "")
  | CreatedAt => Text(entry.created_at)
  | EffectiveAt => Text(entry.effective_at)
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
