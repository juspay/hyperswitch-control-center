open ReconEngineTypes

type resolvingException =
  | ForceReconcile
  | VoidTransaction
  | EditEntry
  | MarkAsReceived
  | CreateNewEntry
  | ReplaceStagingEntryToTransaction
  | LinkStagingEntryToTransaction
  | NoResolutionActionNeeded

type activeModal =
  | IgnoreTransactionModal
  | ForceReconcileModal
  | EditEntryModal
  | CreateEntryModal
  | MarkAsReceivedModal
  | LinkStagingEntriesModal

type resolutionOptionTypes =
  | IgnoreTransaction
  | FixEntries
  | NoResolutionOptionNeeded

type exceptionResolutionStage =
  | ShowResolutionOptions(resolutionOptionTypes)
  | ResolvingException(resolvingException)
  | ConfirmResolution(resolvingException)
  | ExceptionResolved

type accountInfo = {
  account_info_name: string,
  account_info_type: accountTypeVariant,
}

type tableSection = {
  titleElement?: React.element,
  rows: array<array<Table.cell>>,
  rowData: array<RescriptCore.JSON.t>,
}

// Extended entry type for exception resolution with UI-specific fields
type exceptionResolutionEntryType = {
  ...entryType,
  entry_key: string,
}

type accountSection = {
  accountId: string,
  accountInfo: accountInfo,
  accountEntries: array<exceptionResolutionEntryType>,
  accountTotalAmount: float,
  accountCurrency: string,
}

type entryOverrides = {
  entry_type: entryDirectionType,
  amount: float,
  effective_at: string,
  metadata: JSON.t,
  order_id: string,
  transformation_id?: string,
}

type stagingEntryOverrides = {
  effective_at: string,
  metadata: JSON.t,
  order_id: string,
}

@tag("kind")
type newEntry =
  | @as("direct")
  Direct({
      account_id: string,
      entry_type: entryDirectionType,
      amount: float,
      effective_at: string,
      metadata: JSON.t,
      order_id: string,
      transformation_id?: string,
    })

@tag("op")
type entryOp =
  | @as("update_entry") UpdateEntry({entry_id: string, overrides: entryOverrides})
  | @as("mark_received") MarkReceived({entry_id: string, overrides: entryOverrides})
  | @as("create_entry") CreateEntry({entry: newEntry})
  | @as("create_with_staging_entry")
  CreateWithStagingEntry({
      staging_entry_id: string,
      overrides?: stagingEntryOverrides,
    })
  | @as("replace_with_staging_entry")
  ReplaceWithStagingEntry({
      entry_id: string,
      staging_entry_id: string,
      overrides?: stagingEntryOverrides,
    })

type entryChange = {
  op: entryOp,
  entry: exceptionResolutionEntryType,
}

type manualReconciliationRequest = {
  entry_ops: array<entryOp>,
  reason: string,
}
