type processedEntryType = {
  entry_id: string,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  expected: string,
  effective_at: string,
  created_at: string,
}

type processingEntryType = {
  staging_entry_id: string,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  effective_at: string,
}

type accountType = {
  account_name: string,
  account_id: string,
  currency: string,
  pending_balance: string,
  posted_balance: string,
}

type processedColType =
  | EntryId
  | EntryType
  | Amount
  | Currency
  | Status
  | EffectiveAt

type processingColType =
  | StagingEntryId
  | EntryType
  | Amount
  | Currency
  | Status
  | EffectiveAt

let processedItemToObjMapper = dict => {
  open LogicUtils
  {
    entry_id: dict->getString("entry_id", ""),
    entry_type: dict->getString("entry_type", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", ""),
    expected: dict->getString("expected", ""),
    effective_at: dict->getString("effective_at", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let processingItemToObjMapper = dict => {
  open LogicUtils
  {
    staging_entry_id: dict->getString("staging_entry_id", ""),
    entry_type: dict->getString("entry_type", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", ""),
    effective_at: dict->getString("effective_at", ""),
  }
}

let processedDefaultColumns = [EntryId, EntryType, Amount, Currency, Status, EffectiveAt]

let getProcessedHeading = colType => {
  switch colType {
  | EntryId => Table.makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  }
}

let getProcessedCell = (data: processedEntryType, colType): Table.cell => {
  switch colType {
  | EntryId => Text(data.entry_id)
  | EntryType => Text(data.entry_type)
  | Amount => Numeric(data.amount, amount => amount->Float.toString)
  | Currency => Text(data.currency)
  | Status =>
    Label({
      title: data.status->String.toUpperCase,
      color: switch data.status->String.toLowerCase {
      | "posted" => LabelGreen
      | "pending" => LabelBlue
      | "processed" => LabelGreen
      | "failed" => LabelRed
      | "cancelled" => LabelGray
      | _ => LabelLightGray
      },
    })
  | EffectiveAt => Text(data.effective_at)
  }
}

let processedTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns=processedDefaultColumns,
  ~getHeading=getProcessedHeading,
  ~getCell=getProcessedCell,
  ~dataKey="",
)

let processingDefaultColumns = [StagingEntryId, EntryType, Amount, Currency, Status, EffectiveAt]

let getProcessingHeading = colType => {
  switch colType {
  | StagingEntryId => Table.makeHeaderInfo(~key="staging_entry_id", ~title="Staging Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
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
  | Amount => Numeric(data.amount, amount => {amount->Float.toString})
  | Currency => Text(data.currency)
  | Status =>
    Label({
      title: data.status->String.toUpperCase,
      color: switch data.status->String.toLowerCase {
      | "posted" => LabelGreen
      | "pending" => LabelBlue
      | "processed" => LabelGreen
      | "processing" => LabelOrange
      | "needs_manual_review" => LabelOrange
      | "failed" => LabelRed
      | "cancelled" => LabelGray
      | _ => LabelLightGray
      },
    })
  | EffectiveAt => Text(data.effective_at)
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
