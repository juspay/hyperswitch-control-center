open ReconEngineExceptionTypes

type processingColType =
  | StagingEntryId
  | EntryType
  | AccountName
  | Amount
  | Currency
  | Status
  | EffectiveAt

let processingDefaultColumns = [
  StagingEntryId,
  EntryType,
  AccountName,
  Amount,
  Currency,
  Status,
  EffectiveAt,
]
let fileManagementStagingDefaultColumns = [StagingEntryId, EntryType, Amount, Currency, EffectiveAt]

let getProcessingHeading = colType => {
  switch colType {
  | StagingEntryId => Table.makeHeaderInfo(~key="staging_entry_id", ~title="Staging Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | AccountName => Table.makeHeaderInfo(~key="account", ~title="Account")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  }
}

let getProcessingCell = (data: processingEntryType, colType): Table.cell => {
  switch colType {
  | StagingEntryId => Text(data.staging_entry_id)
  | EntryType => Text(data.entry_type)
  | AccountName => Text(data.account.account_name)
  | Amount => Numeric(data.amount, amount => {amount->Float.toString})
  | Currency => Text(data.currency)
  | Status =>
    Label({
      title: data.status->String.toUpperCase,
      color: switch data.status->String.toLowerCase {
      | "pending" => LabelBlue
      | "processed" => LabelGreen
      | "needs_manual_review" => LabelOrange
      | _ => LabelGray
      },
    })
  | EffectiveAt => Date(data.effective_at)
  }
}

let processingTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns=processingDefaultColumns,
  ~getHeading=getProcessingHeading,
  ~getCell=getProcessingCell,
  ~dataKey="",
)

let fileManagementStagingEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns=fileManagementStagingDefaultColumns,
  ~getHeading=getProcessingHeading,
  ~getCell=getProcessingCell,
  ~dataKey="",
)
