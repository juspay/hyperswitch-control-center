open ReconEngineTypes

type entryColType =
  | EntryId
  | EntryType
  | AccountName
  | TransactionId
  | Amount
  | Currency
  | Status
  | Metadata
  | CreatedAt
  | EffectiveAt
  | OrderID

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
  OrderID,
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
  OrderID,
]

let detailsFields = [
  EntryId,
  EntryType,
  AccountName,
  Amount,
  Currency,
  TransactionId,
  Status,
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
  | OrderID => Table.makeHeaderInfo(~key="order_id", ~title="Order ID")
  }
}

let getStatusLabel = (entryStatus: entryStatus): Table.cell => {
  Table.Label({
    title: (entryStatus :> string)->String.toUpperCase,
    color: switch entryStatus {
    | Posted => LabelGreen
    | Mismatched => LabelRed
    | Expected => LabelBlue
    | Archived => LabelGray
    | Pending => LabelOrange
    | _ => LabelLightGray
    },
  })
}

let getCell = (entry: entryType, colType: entryColType): Table.cell => {
  switch colType {
  | EntryId => EllipsisText(entry.entry_id, "w-fit")
  | EntryType => Text((entry.entry_type :> string)->LogicUtils.capitalizeString)
  | AccountName => Text(entry.account_name)
  | TransactionId => Text(entry.transaction_id)
  | Amount => Text(Float.toString(entry.amount))
  | Currency => Text(entry.currency)
  | Status =>
    switch entry.discarded_status {
    | Some(discardedStatus) =>
      getStatusLabel(discardedStatus->ReconEngineUtils.getEntryStatusVariantFromString)
    | None => getStatusLabel(entry.status)
    }
  | Metadata => Text(entry.metadata->JSON.stringify)
  | CreatedAt => Date(entry.created_at)
  | EffectiveAt => Date(entry.effective_at)
  | OrderID => EllipsisText(entry.order_id, "w-fit")
  }
}

let entriesEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
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
