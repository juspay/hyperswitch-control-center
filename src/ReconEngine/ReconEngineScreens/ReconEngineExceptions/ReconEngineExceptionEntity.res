open ReconEngineTypes

type processingColType =
  | StagingEntryId
  | EntryType
  | AccountName
  | Amount
  | Currency
  | Status
  | EffectiveAt
  | Actions

let processingDefaultColumns = [
  StagingEntryId,
  EntryType,
  AccountName,
  Amount,
  Currency,
  Status,
  EffectiveAt,
  Actions,
]

let getProcessingHeading = colType => {
  switch colType {
  | StagingEntryId => Table.makeHeaderInfo(~key="staging_entry_id", ~title="Staging Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | AccountName => Table.makeHeaderInfo(~key="account", ~title="Account")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~customWidth="min-w-48")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getStatusLabel = (status: processingEntryStatus): Table.cell => {
  Label({
    title: (status :> string)->String.toUpperCase,
    color: switch status {
    | Pending => LabelBlue
    | Processed => LabelGreen
    | NeedsManualReview => LabelOrange
    | _ => LabelGray
    },
  })
}

let getProcessingCell = (data: processingEntryType, colType): Table.cell => {
  switch colType {
  | StagingEntryId => EllipsisText(data.staging_entry_id, "")
  | EntryType => Text(data.entry_type)
  | AccountName => EllipsisText(data.account.account_name, "")
  | Amount => Numeric(data.amount, amount => {amount->Float.toString})
  | Currency => Text(data.currency)
  | Status => getStatusLabel(data.status)
  | EffectiveAt => Date(data.effective_at)
  | Actions => CustomCell(<ReconEngineAccountsTransformedEntriesActions processingEntry=data />, "")
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
